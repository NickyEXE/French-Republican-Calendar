package com.example.republican_calendar.widgets

import android.appwidget.AppWidgetProvider
import android.appwidget.AppWidgetManager
import android.content.Context
import android.widget.RemoteViews
import android.util.Log
import com.example.republican_calendar.R
import org.json.JSONObject
import java.io.InputStream
import java.nio.charset.Charset
import java.util.Calendar

class RepublicanCalendarWidget : AppWidgetProvider() {

    override fun onUpdate(context: Context?, appWidgetManager: AppWidgetManager?, appWidgetIds: IntArray?) {
        Log.d("Widget", "🔄 onUpdate() called - Updating widget")

        val today = Calendar.getInstance()
        val republicanDate = getRepublicanDate(context, today)

        appWidgetIds?.forEach { widgetId ->
            val views = RemoteViews(context?.packageName, R.layout.widget_layout)
            val (dedication, date, year) = republicanDate.split(" - ")

            views.setTextViewText(R.id.widget_dedication, dedication)
            views.setTextViewText(R.id.widget_date, date)
            views.setTextViewText(R.id.widget_year, year)
            appWidgetManager?.updateAppWidget(widgetId, views)
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
