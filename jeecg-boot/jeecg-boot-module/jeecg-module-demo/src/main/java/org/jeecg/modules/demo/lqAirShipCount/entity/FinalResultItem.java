package org.jeecg.modules.demo.lqAirShipCount.entity;

// 定义最终输出的结果项类
public class FinalResultItem {
    private String name;
    private int value;
    private String type;

    public FinalResultItem(String name, int value, String type) {
        this.name = name;
        this.value = value;
        this.type = type;
    }

    public String getName() {
        return name;
    }

    public int getValue() {
        return value;
    }

    public String getType() {
        return type;
    }
}
