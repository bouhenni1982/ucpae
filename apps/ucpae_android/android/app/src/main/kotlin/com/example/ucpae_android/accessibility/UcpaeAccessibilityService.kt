package com.example.ucpae_android.accessibility

import android.accessibilityservice.AccessibilityService
import android.view.accessibility.AccessibilityEvent
import io.flutter.plugin.common.EventChannel

class UcpaeAccessibilityService : AccessibilityService() {
    companion object {
        var sink: EventChannel.EventSink? = null
    }

    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        if (event == null || sink == null) return

        val payload = hashMapOf<String, Any?>(
            "type" to mapEventType(event.eventType),
            "role" to inferRole(event.className?.toString()),
            "name" to (event.contentDescription?.toString()
                ?: event.text?.joinToString(" ")
                ?: "Unnamed"),
            "packageName" to (event.packageName?.toString() ?: ""),
            "sourcePlatform" to "android"
        )

        sink?.success(payload)
    }

    override fun onInterrupt() = Unit

    private fun mapEventType(eventType: Int): String {
        return when (eventType) {
            AccessibilityEvent.TYPE_VIEW_CLICKED -> "click"
            AccessibilityEvent.TYPE_VIEW_SCROLLED -> "scroll"
            else -> "focus"
        }
    }

    private fun inferRole(className: String?): String {
        return when {
            className == null -> "unknown"
            className.contains("Button", ignoreCase = true) -> "button"
            className.contains("CheckBox", ignoreCase = true) -> "checkbox"
            else -> "control"
        }
    }
}
