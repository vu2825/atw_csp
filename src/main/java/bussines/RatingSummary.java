package bussines;

import java.util.HashMap;
import java.util.Map;

public class RatingSummary {
    private double avg;
    private int count;
    private Map<Integer, Integer> dist = new HashMap<>();

    public double getAvg() { return avg; }
    public void setAvg(double avg) { this.avg = avg; }

    public int getCount() { return count; }
    public void setCount(int count) { this.count = count; }

    public Map<Integer, Integer> getDist() { return dist; }
    public void setDist(Map<Integer, Integer> dist) { this.dist = dist; }
}
