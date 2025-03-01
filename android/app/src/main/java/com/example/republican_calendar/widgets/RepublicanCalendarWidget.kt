package com.example.republican_calendar.widgets

import android.app.AlarmManager
import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.os.Build
import android.util.Log
import android.widget.RemoteViews
import com.example.republican_calendar.R
import org.json.JSONObject
import java.io.InputStream
import java.nio.charset.Charset
import java.util.Calendar
import java.util.concurrent.TimeUnit

class RepublicanCalendarWidget : AppWidgetProvider() {

    companion object {
        private const val PREFS_NAME = "com.example.republican_calendar.widgets.RepublicanCalendarWidget"
        private const val UPDATE_WIDGET = "com.example.republican_calendar.widgets.UPDATE_WIDGET"
        private const val MIDNIGHT_UPDATE_REQUEST_CODE = 101
        private const val TEN_MINUTE_UPDATE_REQUEST_CODE = 102
        private const val UPDATE_INTERVAL_MINUTES = 10L
    }

    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray) {
        Log.d("Widget", "🔄 onUpdate() called - Updating widget")
        updateWidgetContent(context, appWidgetManager, appWidgetIds)
    }

    override fun onEnabled(context: Context) {
        super.onEnabled(context)
        Log.d("Widget", "Widget enabled - Starting alarms")
        startMidnightAlarm(context)
        startTenMinuteAlarm(context)
    }

    override fun onDisabled(context: Context) {
        super.onDisabled(context)
        Log.d("Widget", "Widget disabled - Stopping alarms")
        cancelMidnightAlarm(context)
        cancelTenMinuteAlarm(context)
    }

    private fun updateWidgetContent(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray) {
        val today = Calendar.getInstance()
        val republicanDate = getRepublicanDate(context, today)

        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.widget_layout)
            val (dedication, date, year) = republicanDate.split(" - ")

            views.setTextViewText(R.id.widget_dedication, dedication)
            views.setTextViewText(R.id.widget_date, date)
            views.setTextViewText(R.id.widget_year, year)
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }

    private fun startMidnightAlarm(context: Context) {
        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        val intent = Intent(context, RepublicanCalendarWidget::class.java).apply {
            action = UPDATE_WIDGET
        }
        val pendingIntent = PendingIntent.getBroadcast(context, MIDNIGHT_UPDATE_REQUEST_CODE, intent, PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT)

        val midnight = Calendar.getInstance().apply {
            timeInMillis = System.currentTimeMillis()
            set(Calendar.HOUR_OF_DAY, 0)
            set(Calendar.MINUTE, 0)
            set(Calendar.SECOND, 0)
            set(Calendar.MILLISECOND, 0)
            add(Calendar.DAY_OF_MONTH, 1)
        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            alarmManager.setExactAndAllowWhileIdle(AlarmManager.RTC, midnight.timeInMillis, pendingIntent)
        } else {
            alarmManager.setExact(AlarmManager.RTC, midnight.timeInMillis, pendingIntent)
        }
    }

    private fun startTenMinuteAlarm(context: Context) {
        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        val intent = Intent(context, RepublicanCalendarWidget::class.java).apply {
            action = UPDATE_WIDGET
        }
        val pendingIntent = PendingIntent.getBroadcast(context, TEN_MINUTE_UPDATE_REQUEST_CODE, intent, PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT)

        val tenMinutes = TimeUnit.MINUTES.toMillis(UPDATE_INTERVAL_MINUTES)
        val now = System.currentTimeMillis()

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            alarmManager.setRepeating(AlarmManager.RTC, now + tenMinutes, tenMinutes, pendingIntent)
        } else {
            alarmManager.setRepeating(AlarmManager.RTC, now + tenMinutes, tenMinutes, pendingIntent)
        }
    }

    private fun cancelMidnightAlarm(context: Context) {
        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        val intent = Intent(context, RepublicanCalendarWidget::class.java).apply {
            action = UPDATE_WIDGET
        }
        val pendingIntent = PendingIntent.getBroadcast(context, MIDNIGHT_UPDATE_REQUEST_CODE, intent, PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT)
        alarmManager.cancel(pendingIntent)
    }

    private fun cancelTenMinuteAlarm(context: Context) {
        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        val intent = Intent(context, RepublicanCalendarWidget::class.java).apply {
            action = UPDATE_WIDGET
        }
        val pendingIntent = PendingIntent.getBroadcast(context, TEN_MINUTE_UPDATE_REQUEST_CODE, intent, PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT)
        alarmManager.cancel(pendingIntent)
    }

    override fun onReceive(context: Context?, intent: Intent?) {
        super.onReceive(context, intent)
        if (intent?.action == UPDATE_WIDGET) {
            Log.d("Widget", "Received update intent")
            val appWidgetManager = AppWidgetManager.getInstance(context)
            val componentName = ComponentName(context!!, RepublicanCalendarWidget::class.java)
            val appWidgetIds = appWidgetManager.getAppWidgetIds(componentName)
            updateWidgetContent(context, appWidgetManager, appWidgetIds)
        }
    }

    public fun getRepublicanDate(context: Context?, today: Calendar): String {
        val republicanYear = calculateRepublicanYear(today)

        val start = Calendar.getInstance().apply {
            set(1792, Calendar.SEPTEMBER, 22)
        }

        val dayDiff = ((today.timeInMillis - start.timeInMillis) / (1000 * 60 * 60 * 24)).toInt() + 1

        var yearCounter = 1
        var startDay = 1

        while (true) {
            val endDay = startDay + if (isRepublicanLeapYear(yearCounter)) 365 else 364

            if (endDay >= dayDiff) {
                break
            }

            yearCounter += 1
            startDay = endDay + 1
        }

        val dayInYear = dayDiff - startDay

        val monthIndex = dayInYear / 30
        val dayInMonth = dayInYear % 30

        val months = listOf(
            "Vendémiaire", "Brumaire", "Frimaire", "Nivôse", "Pluviôse", "Ventôse",
            "Germinal", "Floréal", "Prairial", "Messidor", "Thermidor", "Fructidor",
            "Sansculottides"
        )

        val key = "${dayInMonth + 1}_${months[monthIndex]}"
        val dedication = getDedication(context, key)

        return "${dedication["fr"]} - ${dayInMonth + 1} ${months[monthIndex]} - Year $republicanYear"
    }

    private fun getDedication(context: Context?, key: String): Map<String, String> {
        val inputStream: InputStream = context!!.assets.open("dedications.json")
        val jsonString = inputStream.readBytes().toString(Charset.defaultCharset())
        val jsonObject = JSONObject(jsonString)
        val dedication = jsonObject.getJSONObject(key)
        return mapOf("fr" to dedication.getString("fr"), "eng" to dedication.getString("eng"))
    }

    private fun calculateRepublicanYear(today: Calendar): Int {
        val year = today.get(Calendar.YEAR)
        val month = today.get(Calendar.MONTH) + 1
        val day = today.get(Calendar.DAY_OF_MONTH)

        return year - 1792 + if (month > 9 || (month == 9 && day >= 22)) 1 else 0
    }

    private fun isRepublicanLeapYear(year: Int): Boolean {
        val firstLeapYears = listOf(3, 7, 11, 15, 20)
        if (year <= firstLeapYears.last()) {
            return firstLeapYears.contains(year)
        }
        return (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0)
    }
}
