package com.company;

public class ThreadMin extends Thread {
    // Початковий індекс діапазону
    private final int startIndex;
    // Кінцевий індекс діапазону (не включно)
    private final int finishIndex;
    // Об'єкт класу ArayClass
    private final ArayClass arrClass;
    public ThreadMin(int startIndex, int finishIndex, ArayClass arrClass) {
        this.startIndex = startIndex;
        this.finishIndex = finishIndex;
        this.arrClass = arrClass;
    }
    @Override
    public void run() {
        // Пошук мінімального елемента в діапазоні [startIndex, finishIndex)
        long min = arrClass.OneThreadMin(startIndex, finishIndex);
        // Передача знайденого мінімального значення до методу collectMin класу ArayClass
        arrClass.collectMin(min);
        // Повідомлення про завершення потоку
        arrClass.incThreadCount();
    }
}