import java.util.Scanner;

public class Main {
    public static void main(String[] args) {
        Scanner scanner = new Scanner(System.in);  // Створюємо обьект за назвою scanner для читання даних
        System.out.print("Введіть крок: ");  // вводимо значення кроку
        int step = scanner.nextInt();        // Зчитуємо введене значення кроку та зберігає його в змінній step
        System.out.print("Введіть кількість потоків: ");  // Запитує користувача ввести кількість потоків
        int numThreads = scanner.nextInt();  // Зчитує введену кількість потоків та зберігає її в змінній numThreads
        int permissionInterval = 10000;  // Інтервал дозволу виконання потоків у мілісекундах 10 секунд
        SummingThread[] threads = new SummingThread[numThreads];  // Створює масив потоків розміром numThreads

        for (int i = 0; i < numThreads; i++) {
            threads[i] = new SummingThread(i, step);  // Створює новий об'єкт SummingThread для кожного елемента масиву та ініціалізує його з id та значенням кроку step
            threads[i].start();                        // Запускає виконання потоку
        }

        try {
            Thread.sleep(permissionInterval);  // Зупиняє головний потік на час permissionInterval
        } catch (InterruptedException e) {
            e.printStackTrace();  // Виводить повідомлення про помилку, якщо виникає переривання
        }

        for (int i = 0; i < numThreads; i++) {
            threads[i].setRunning(false);  // Сигналізує кожному потоку про зупинку, встановивши running у false
        }
    }

    private static class SummingThread extends Thread {
        private final int id; // Поле для ідентифікатора потоку
        private final int step;  // Поле для значення кроку
        private volatile boolean running = true; // визначає стан потоку true - працює

        public SummingThread(int id, int step) { // Конструктор, який ініціалізує поля id та step
            this.id = id;
            this.step = step;
        }

        public void run() {  // Метод run який виконується при запуску потоку
            double sum = 0; // Змінна для зберігання часткової суми
            double count = 0; // Змінна для підрахунку кількості ітерацій
            double current = 0;  // Поточне значення, яке додається до суми

            while (running) { // Цикл while який триває доки running має значення true
                sum += current;
                count++;
                current += step;
            }
            System.out.printf("Thread %d: sum=%f count=%f2\n", id + 1, sum, count);
        }

        public void setRunning(boolean running) { // змінює значення running
            this.running = running;
        }
    }
}
