package com.company;

import java.util.Random;

public class ArayClass {
    // Кількість елементів в масиві
    private final int number_of_cells;
    // Кількість потоків
    private final int threadNum;

    // Масив елементів
    public final int[] arr;


    // Конструктор класу
    public ArayClass(int number_of_cells, int threadNum) {
        this.number_of_cells = number_of_cells;
        arr = new int[number_of_cells];
        this.threadNum = threadNum;

        // Ініціалізація масиву значеннями від 0 до number_of_cells - 1
        for (int i = 0; i < number_of_cells; i++) {
            arr[i] = i;
        }

        // Створюємо Random-об'єкт
        Random random = new Random();

        // Змінюємо знак одного випадкового елемента на протилежний
        arr[random.nextInt(number_of_cells)] *= -1;
    }

    // Пошук мінімального елемента в [startIndex, finishIndex) за допомогою одного потоку
    public long OneThreadMin(int startIndex, int finishIndex) {
        long min = Long.MAX_VALUE;
        // Перебираємо елементи в заданому діапазоні
        for (int i = startIndex; i < finishIndex; i++) {
            if (min > arr[i]) {
                min = arr[i];
            }
        }
        return min;
    }

    // Змінна для зберігання знайденого мінімального значення
    private long min = 0;

    // Синхронізований метод для отримання знайденого мінімального значення
    synchronized private long getMin() {
        // Чекаємо, поки всі потоки завершать роботу
        while (getThreadCount() < threadNum) {
            try {
                wait();
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
        }
        return min;
    }

    // Синхронізований метод для оновлення знайденого мінімального значення
    synchronized public void collectMin(long min) {
        // Оновлюємо min, якщо нове значення менше
        if (this.min > min) {
            this.min = min;
        }
    }

    // Змінна для підрахунку кількості завершених потоків
    private int threadCount = 0;

    // Синхронізований метод для збільшення лічильника завершених потоків
    synchronized public void incThreadCount() {
        threadCount++;
        // Повідомляємо про зміну змінної threadCount
        notify();
    }

    // Отримання кількості завершених потоків
    private int getThreadCount() {
        return threadCount;
    }

    // Пошук мінімального елемента в масиві за допомогою n потоків
    public long threadMin() {
        // Створюємо масив потоків ThreadMin
        ThreadMin[] threadMins = new ThreadMin[threadNum];

        // Розраховуємо крок між межами діапазонів для потоків
        int len = number_of_cells / threadNum;

        // Створюємо та запускаємо потоки ThreadMin
        for (int i = 0; i < threadNum - 1; i++) {
            threadMins[i] = new ThreadMin(len * i, len * (i + 1), this);
            threadMins[i].start();
        }
        threadMins[threadNum - 1] = new ThreadMin(len * (threadNum - 1), number_of_cells, this);
        threadMins[threadNum - 1].start();

        // Очікуємо завершення всіх потоків та отримуємо знайдене мінімальне значення
        return getMin();
    }
}
