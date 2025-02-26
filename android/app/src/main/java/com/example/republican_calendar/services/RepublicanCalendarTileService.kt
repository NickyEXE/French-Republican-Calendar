package com.example.republican_calendar.services

import android.content.Intent
import android.service.quicksettings.TileService
import android.service.quicksettings.Tile
import android.util.Log
import com.example.republican_calendar.MainActivity
import com.example.republican_calendar.widgets.RepublicanCalendarWidget
import java.util.Calendar

class RepublicanCalendarTileService : TileService() {

    override fun onStartListening() {
        super.onStartListening()
        Log.d("TileService", "🔄 onStartListening() called - Updating tile")

        val today = Calendar.getInstance()
        val republicanDate = RepublicanCalendarWidget().getRepublicanDate(applicationContext, today)
        val (dedication, date, year) = republicanDate.split(" - ")

        qsTile.label = "$date $year"
        qsTile.state = Tile.STATE_ACTIVE
        qsTile.updateTile()
    }

    override fun onClick() {
        super.onClick()
        Log.d("TileService", "🔄 onClick() called - Tile clicked")
        
        val intent = Intent(this, MainActivity::class.java)
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        startActivityAndCollapse(intent)
    }
}
