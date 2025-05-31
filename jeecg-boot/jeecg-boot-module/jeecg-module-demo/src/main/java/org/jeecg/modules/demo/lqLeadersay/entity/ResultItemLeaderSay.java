package org.jeecg.modules.demo.lqLeadersay.entity;

// 定义结果项类，用于存储每个结果的年份和标题信息
public class ResultItemLeaderSay{
    private String year;
    private String title;

    // 构造函数，用于初始化年份和标题
    public ResultItemLeaderSay(String year, String title) {
        this.year = year;
        this.title = title;
    }

    // 获取年份的方法
    public String getYear() {
        return year;
    }

    // 获取标题的方法
    public String getTitle() {
        return title;
    }
}