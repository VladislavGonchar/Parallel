package com.company;

public class Main {
    public static void main(String[] args) {
        // Кількість елементів в масиві
        int number_of_cells = 100000000;
        // Кількість потоків
        int threadNum = 4;                                                  //Кількість потоків
        // Засікаємо час виконання пошуку мінімального елемента одним потоком
        long time = System.nanoTime();
        // Створення об'єкта класу ArayClass
        ArayClass arrClass = new ArayClass(number_of_cells, threadNum);
        // Пошук мінімального елемента одним потоком
        long minIndex = arrClass.OneThreadMin(0, number_of_cells);
        // Обчислення часу виконання пошуку одним потоком
        time = System.nanoTime() - time;
        // Виведення на екран мінімального елемента та часу виконання пошуку одним потоком
        System.out.println(minIndex + " time:" + time);
        // Засікаємо час виконання пошуку мінімального елемента n потоками
        time = System.nanoTime();
        // Пошук мінімального елемента n потоками
        minIndex = arrClass.threadMin();
        // Обчислення часу виконання пошуку n потоками
        time = System.nanoTime() - time;
        // Виведення на екран мінімального елемента та часу виконання пошуку n потоками
        System.out.println(minIndex + " time:" + time);
    }
}