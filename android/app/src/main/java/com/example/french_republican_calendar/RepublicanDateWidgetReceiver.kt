package com.example.french_republican_calendar

import android.appwidget.AppWidgetProvider
import android.content.Context
import android.appwidget.AppWidgetManager
import android.widget.RemoteViews
import com.example.french_republican_calendar.R
import android.content.Intent

class RepublicanDateWidgetReceiver : AppWidgetProvider() {
    override fun onUpdate(
        context: Context?,
        appWidgetManager: AppWidgetManager?,
        appWidgetIds: IntArray?
    ) {
        appWidgetIds?.forEach { widgetId ->
            val views = RemoteViews(context?.packageName, R.layout.widget_layout)
            views.setTextViewText(R.id.widget_text, "French Republican Date")

            appWidgetManager?.updateAppWidget(widgetId, views)
        }
    }
}
