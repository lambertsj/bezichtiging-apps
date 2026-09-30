package com.jeroenlamberts.bezichtiging.models

enum class Market(val value: String) {
    NL("nl"), UK("uk"), US("us");

    val label: String get() = when (this) {
        NL -> "Nederland"; UK -> "United Kingdom"; US -> "United States"
    }
    val flag: String get() = when (this) {
        NL -> "🇳🇱"; UK -> "🇬🇧"; US -> "🇺🇸"
    }
    val isEnglish: Boolean get() = this == UK || this == US

    companion object {
        val onboardingMarkets = listOf(NL)

        val isDeviceLanguageDutch: Boolean
            get() = true

        fun onboardingDefault(): Market = NL

        fun fromValue(value: String): Market =
            entries.firstOrNull { it.value == value } ?: NL
    }
}
