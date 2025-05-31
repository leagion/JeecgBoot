package org.jeecg.modules.demo.lqIncidentInfo.entity;

public class StatisticResultItem {
    private int value;
    private String name;
    public StatisticResultItem(int value, String name) {
        this.value = value;
        this.name = name;
    }
    public int getValue() {
        return value;
    }
    public String getName() {
        return name;
    }
}
