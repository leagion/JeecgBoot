package org.jeecg.modules.demo.lqAirShipCount.entity;

public class AirshipResultItem {

    private String name;
    private int aircraftCount;
    private int shipCount;
    public AirshipResultItem(String name) {
        this.name = name;
        this.aircraftCount = 0;
        this.shipCount = 0;
    }
    public String getName() {
        return name;
    }
    public int getAircraftCount() {
        return aircraftCount;
    }
    public void setAircraftCount(int aircraftCount) {
        this.aircraftCount = aircraftCount;
    }
    public int getShipCount() {
        return shipCount;
    }
    public void setShipCount(int shipCount) {
        this.shipCount = shipCount;
    }
}

