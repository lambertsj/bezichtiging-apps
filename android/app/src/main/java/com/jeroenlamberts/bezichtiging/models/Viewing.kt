package com.jeroenlamberts.bezichtiging.models

import java.util.UUID

enum class ViewingType(val value: String) {
    WONING("woning"), APPARTEMENT("appartement");

    fun label(market: Market): String {
        if (Market.isDeviceLanguageDutch) return if (this == WONING) "Woning" else "Appartement"
        return if (this == WONING) "House" else if (market == Market.UK) "Flat" else "Apartment"
    }

    fun sub(market: Market): String {
        if (Market.isDeviceLanguageDutch) {
            return if (this == WONING) "Eengezins, hoek, vrijstaand" else "Onderdeel van een VvE"
        }
        return if (this == WONING) "Terraced, semi-detached, detached" else "Part of a building or block"
    }

    val systemIcon: String get() = if (this == WONING) "Home" else "Apartment"

    companion object {
        fun fromValue(v: String) = entries.firstOrNull { it.value == v } ?: WONING
    }
}

enum class Tenure(val value: String) {
    KOOP("koop"), HUUR("huur");

    fun label(market: Market): String {
        if (Market.isDeviceLanguageDutch) return if (this == KOOP) "Koop" else "Huur"
        return if (this == KOOP) "Purchase" else "Rental"
    }

    fun longLabel(market: Market): String {
        if (Market.isDeviceLanguageDutch) return if (this == KOOP) "Te koop" else "Te huur"
        if (this == KOOP) return "For Sale"
        return if (market == Market.UK) "To Let" else "For Rent"
    }

    val systemIcon: String get() = if (this == KOOP) "VpnKey" else "Sell"

    companion object {
        fun fromValue(v: String) = entries.firstOrNull { it.value == v } ?: KOOP
    }
}

enum class Rating(val value: String) {
    GOED("goed"), NIET("niet"), NA("na");

    fun reportBadge(isDutch: Boolean): String = when (this) {
        GOED -> if (isDutch) "In orde" else "Good"
        NIET -> if (isDutch) "Aandacht" else "Attention"
        NA   -> if (isDutch) "N.v.t." else "N/A"
    }

    companion object {
        fun fromValue(v: String) = entries.firstOrNull { it.value == v } ?: GOED
    }
}

data class Viewing(
    val id: String = UUID.randomUUID().toString(),
    val name: String = "",
    val type: ViewingType = ViewingType.WONING,
    val tenure: Tenure = Tenure.KOOP,
    val date: Long = System.currentTimeMillis(),
    val answers: Map<String, String> = emptyMap(),   // key → Rating.value
    val notes: Map<String, String> = emptyMap(),
    val photoIds: Map<String, List<String>> = emptyMap(),
    val itemPhotoIds: Map<String, List<String>> = emptyMap(),
    val itemNotes: Map<String, String> = emptyMap(),
    val market: String = Market.NL.value
) {
    fun rating(key: String): Rating? = answers[key]?.let { Rating.fromValue(it) }
    fun marketEnum(): Market = Market.fromValue(market)

    data class Score(val goed: Int, val total: Int)
    fun score(): Score {
        val total = answers.size
        val goed = answers.values.count { it == Rating.GOED.value }
        return Score(goed, total)
    }
}
