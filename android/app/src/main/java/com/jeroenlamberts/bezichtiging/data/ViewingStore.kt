package com.jeroenlamberts.bezichtiging.data

import android.content.Context
import android.graphics.Bitmap
import androidx.lifecycle.ViewModel
import com.jeroenlamberts.bezichtiging.models.*
import com.google.gson.Gson
import com.google.gson.reflect.TypeToken
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import java.util.UUID

class ViewingStore(private val context: Context) : ViewModel() {

    private val prefs = context.getSharedPreferences("bz_prefs", Context.MODE_PRIVATE)
    private val gson = Gson()

    private val saveKey = "bz.viewings.v2"
    private val marketKey = "bz.market"
    private val onboardingKey = "bz.onboarded"

    private val _viewings = MutableStateFlow<List<Viewing>>(emptyList())
    val viewings: StateFlow<List<Viewing>> = _viewings.asStateFlow()

    private val _market = MutableStateFlow(Market.NL)
    val market: StateFlow<Market> = _market.asStateFlow()

    private val _hasCompletedOnboarding = MutableStateFlow(false)
    val hasCompletedOnboarding: StateFlow<Boolean> = _hasCompletedOnboarding.asStateFlow()

    init {
        val storedMarket = prefs.getString(marketKey, null)
        val onboarded = prefs.getBoolean(onboardingKey, false) || storedMarket != null
        _hasCompletedOnboarding.value = onboarded
        if (storedMarket != null) _market.value = Market.fromValue(storedMarket)
        load()
    }

    fun completeOnboarding(m: Market) {
        _market.value = m
        prefs.edit().putString(marketKey, m.value).putBoolean(onboardingKey, true).apply()
        _hasCompletedOnboarding.value = true
    }

    fun setMarket(m: Market) {
        _market.value = m
        prefs.edit().putString(marketKey, m.value).apply()
    }

    // MARK: – CRUD

    fun create(name: String, type: ViewingType, tenure: Tenure): String {
        val v = Viewing(
            id = UUID.randomUUID().toString(),
            name = name,
            type = type,
            tenure = tenure,
            market = _market.value.value
        )
        val updated = listOf(v) + _viewings.value
        _viewings.value = updated
        save(updated)
        return v.id
    }

    fun setAnswer(viewingId: String, key: String, rating: Rating?) {
        val updated = _viewings.value.map { v ->
            if (v.id != viewingId) v else {
                val newAnswers = if (rating != null) v.answers + (key to rating.value)
                                 else v.answers - key
                v.copy(answers = newAnswers)
            }
        }
        _viewings.value = updated
        save(updated)
    }

    fun setNote(viewingId: String, entryId: String, text: String) {
        val updated = _viewings.value.map { v ->
            if (v.id != viewingId) v else {
                val newNotes = if (text.isBlank()) v.notes - entryId else v.notes + (entryId to text)
                v.copy(notes = newNotes)
            }
        }
        _viewings.value = updated
        save(updated)
    }

    fun delete(viewingId: String) {
        PhotoStore.deleteAll(context, viewingId)
        val updated = _viewings.value.filter { it.id != viewingId }
        _viewings.value = updated
        save(updated)
    }

    fun deleteAllViewings() {
        _viewings.value.forEach { PhotoStore.deleteAll(context, it.id) }
        _viewings.value = emptyList()
        save(emptyList())
    }

    // MARK: – Entry-level photos

    fun addPhoto(viewingId: String, entryId: String, bitmap: Bitmap): Boolean {
        val v = _viewings.value.firstOrNull { it.id == viewingId } ?: return false
        val existing = v.photoIds[entryId] ?: emptyList()
        if (existing.size >= 2) return false
        val photoId = PhotoStore.save(context, viewingId, bitmap)
        val newIds = existing + photoId
        val updated = _viewings.value.map { if (it.id != viewingId) it else it.copy(photoIds = it.photoIds + (entryId to newIds)) }
        _viewings.value = updated
        save(updated)
        return true
    }

    fun removePhoto(viewingId: String, entryId: String, photoId: String) {
        PhotoStore.delete(context, viewingId, photoId)
        val updated = _viewings.value.map { v ->
            if (v.id != viewingId) v else {
                val newIds = (v.photoIds[entryId] ?: emptyList()) - photoId
                v.copy(photoIds = if (newIds.isEmpty()) v.photoIds - entryId else v.photoIds + (entryId to newIds))
            }
        }
        _viewings.value = updated
        save(updated)
    }

    // MARK: – Item-level photos and notes

    fun addItemPhoto(viewingId: String, itemKey: String, bitmap: Bitmap): Boolean {
        val v = _viewings.value.firstOrNull { it.id == viewingId } ?: return false
        val existing = v.itemPhotoIds[itemKey] ?: emptyList()
        if (existing.size >= 2) return false
        val photoId = PhotoStore.save(context, viewingId, bitmap)
        val newIds = existing + photoId
        val updated = _viewings.value.map { if (it.id != viewingId) it else it.copy(itemPhotoIds = it.itemPhotoIds + (itemKey to newIds)) }
        _viewings.value = updated
        save(updated)
        return true
    }

    fun removeItemPhoto(viewingId: String, itemKey: String, photoId: String) {
        PhotoStore.delete(context, viewingId, photoId)
        val updated = _viewings.value.map { v ->
            if (v.id != viewingId) v else {
                val newIds = (v.itemPhotoIds[itemKey] ?: emptyList()) - photoId
                v.copy(itemPhotoIds = if (newIds.isEmpty()) v.itemPhotoIds - itemKey else v.itemPhotoIds + (itemKey to newIds))
            }
        }
        _viewings.value = updated
        save(updated)
    }

    fun setItemNote(viewingId: String, itemKey: String, text: String) {
        val updated = _viewings.value.map { v ->
            if (v.id != viewingId) v else {
                val newNotes = if (text.isBlank()) v.itemNotes - itemKey else v.itemNotes + (itemKey to text)
                v.copy(itemNotes = newNotes)
            }
        }
        _viewings.value = updated
        save(updated)
    }

    // MARK: – Persistence

    private fun save(viewings: List<Viewing>) {
        prefs.edit().putString(saveKey, gson.toJson(viewings)).apply()
    }

    private fun load() {
        val json = prefs.getString(saveKey, null) ?: return
        val type = object : TypeToken<List<ViewingJson>>() {}.type
        try {
            val raw = gson.fromJson<List<ViewingJson>>(json, type)
            _viewings.value = raw.map { it.toViewing() }
        } catch (e: Exception) {
            // corrupted data: start fresh
        }
    }

    // MARK: – JSON DTO (handles backward compat with null fields from Gson)

    private data class ViewingJson(
        val id: String?,
        val name: String?,
        val type: String?,
        val tenure: String?,
        val date: Long?,
        val answers: Map<String, String>?,
        val notes: Map<String, String>?,
        val photoIds: Map<String, List<String>>?,
        val itemPhotoIds: Map<String, List<String>>?,
        val itemNotes: Map<String, String>?,
        val market: String?
    ) {
        fun toViewing() = Viewing(
            id = id ?: UUID.randomUUID().toString(),
            name = name ?: "",
            type = ViewingType.fromValue(type ?: "woning"),
            tenure = Tenure.fromValue(tenure ?: "koop"),
            date = date ?: System.currentTimeMillis(),
            answers = answers ?: emptyMap(),
            notes = notes ?: emptyMap(),
            photoIds = photoIds ?: emptyMap(),
            itemPhotoIds = itemPhotoIds ?: emptyMap(),
            itemNotes = itemNotes ?: emptyMap(),
            market = market ?: Market.NL.value
        )
    }
}
