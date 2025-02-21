package com.example.republican_calendar.widgets

import com.example.republican_calendar.R
import android.appwidget.AppWidgetProvider
import android.appwidget.AppWidgetManager
import android.content.Context
import android.widget.RemoteViews
import android.content.Intent
import android.app.AlarmManager
import android.app.PendingIntent
import android.util.Log
import org.json.JSONArray
import java.io.InputStream
import java.nio.charset.Charset
import java.util.Calendar

class RepublicanCalendarWidget : AppWidgetProvider() {

    override fun onUpdate(
        context: Context?,
        appWidgetManager: AppWidgetManager?,
        appWidgetIds: IntArray?
    ) {
        Log.d("Widget", "🔄 onUpdate() called - Updating widget")

        val dateText = getRepublicanDate(context)
        Log.d("Widget", "📅 Republican Calendar Date: $dateText")

        appWidgetIds?.forEach { widgetId ->
            val views = RemoteViews(context?.packageName, R.layout.widget_layout)
            views.setTextViewText(R.id.widget_text, dateText)
            appWidgetManager?.updateAppWidget(widgetId, views)
        }
    }

    private fun getRepublicanDate(context: Context?): String {
        val today = Calendar.getInstance()
        val day = today.get(Calendar.DAY_OF_MONTH)
        val month = today.get(Calendar.MONTH) + 1  // Months are 0-based in Java
        val year = today.get(Calendar.YEAR)

        Log.d("Widget", "📅 Today's Gregorian Date: $day ${getMonthAbbreviation(month)}, $year")

        val republicanYear = calculateRepublicanYear(today)
        val isLeapYear = isRepublicanLeapYear(republicanYear)

        Log.d("Widget", "📅 Republican Year: Year $republicanYear")
        Log.d("Widget", "⚡ Is Leap Year: $isLeapYear")

        try {
            val inputStream: InputStream = context!!.assets.open("months.json")
            val jsonString = inputStream.readBytes().toString(Charset.defaultCharset())
            val jsonArray = JSONArray(jsonString)

            for (i in 0 until jsonArray.length()) {
                val monthObject = jsonArray.getJSONObject(i)
                val daysArray = monthObject.getJSONArray("days")

                for (j in 0 until daysArray.length()) {
                    val dayObject = daysArray.getJSONObject(j)

                    // Handle leap year special day (Jour de la Révolution)
                    if (isLeapYear && day == 22 && month == 9 && dayObject.getString("day") == "Jour de la Révolution") {
                        return "Jour de la Révolution - Year $republicanYear"
                    }

                    if (dayObject.getString("gregorianEquivalent") == "$day ${getMonthAbbreviation(month)}") {
                        Log.d("Widget", "📅 Found Republican Date: ${dayObject.getString("day")} ${monthObject.getString("monthName")}")
                        return "${dayObject.getString("day")} ${monthObject.getString("monthName")} - Year $republicanYear"
                    }
                }
            }
        } catch (e: Exception) {
            Log.e("Widget", "Error reading months.json: ${e.message}")
        }
        return "Date Not Available"
    }

    private fun calculateRepublicanYear(today: Calendar): Int {
        val year = today.get(Calendar.YEAR)
        val month = today.get(Calendar.MONTH) + 1
        val day = today.get(Calendar.DAY_OF_MONTH)

        val republicanYear = year - 1792 + if (month > 9 || (month == 9 && day >= 22)) 1 else 0
        return republicanYear
    }

    private fun isRepublicanLeapYear(year: Int): Boolean {
        // Leap year occurs if (year + 1) is divisible by 4
        return (year + 1) % 4 == 0
    }

    private fun getMonthAbbreviation(month: Int): String {
        val monthNames = listOf("Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec")
        return monthNames[month - 1]
    }

    private fun scheduleMidnightUpdate(context: Context?) {
        val alarmManager = context?.getSystemService(Context.ALARM_SERVICE) as? AlarmManager
        val intent = Intent(context, RepublicanCalendarWidget::class.java)
        val pendingIntent = PendingIntent.getBroadcast(
            context, 0, intent, PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        val calendar = Calendar.getInstance().apply {
            set(Calendar.HOUR_OF_DAY, 0)
            set(Calendar.MINUTE, 0)
            set(Calendar.SECOND, 0)
            add(Calendar.DAY_OF_YEAR, 1)  // Schedule for the next midnight
        }

        alarmManager?.setExactAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, calendar.timeInMillis, pendingIntent)
    }
}
