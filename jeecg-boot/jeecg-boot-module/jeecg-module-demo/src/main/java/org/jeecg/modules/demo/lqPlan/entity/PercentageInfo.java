package org.jeecg.modules.demo.lqPlan.entity;


public class PercentageInfo {
    private String name;
    private double value;

    public PercentageInfo(String name, double value) {
        this.name = name;
        this.value = value;
    }
    public String getName() {
        return name;
    }
    public double getValue() {
        return value;
    }
}