package org.jeecg.modules.demo.lqPlan.entity;

import java.io.Serializable;

public class PlanInfo implements Serializable {
    private String mTime;
    private String mPlace;
    private String mPerson;
    private String mVessel;
    private String isAccept;
    private String mContent;

    // 构造函数
    public PlanInfo(String mTime, String mPlace, String mPerson, String mVessel, String isAccept, String mContent) {
        this.mTime = mTime;
        this.mPlace = mPlace;
        this.mPerson = mPerson;
        this.mVessel = mVessel;
        this.isAccept = isAccept; //是否批复
        this.mContent = mContent;
    }

    // Getters 和 Setters
    public String getmTime() {
        return mTime;
    }

    public void setmTime(String mTime) {
        this.mTime = mTime;
    }

    public String getmPlace() {
        return mPlace;
    }

    public void setmPlace(String mPlace) {
        this.mPlace = mPlace;
    }

    public String getmPerson() {
        return mPerson;
    }

    public void setmPerson(String mPerson) {
        this.mPerson = mPerson;
    }

    public String getmVessel() {
        return mVessel;
    }

    public void setmVessel(String mVessel) {
        this.mVessel = mVessel;
    }

    public String getIsAccept() {
        return isAccept;
    }

    public void setIsAccept(String isAccept) {
        this.isAccept = isAccept;
    }

    public String getmContent() {
        return mContent;
    }

    public void setmContent(String mContent) {
        this.mContent = mContent;
    }

}