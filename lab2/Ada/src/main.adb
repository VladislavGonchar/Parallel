
with Ada.Text_IO; use Ada.Text_IO;
with Ada.Numerics.Discrete_Random;
with Ada.Calendar; use Ada.Calendar;

procedure Main is

  -- Постійні, що визначають розмір масиву та кількість потоків
  number_of_cells : constant Long_Long_Integer := 200000; -- Кількість елементів в масиві
  thread_num : constant Long_Long_Integer := 2; -- Кількість потоків для пошуку мінімального значення
  index_random: Long_Long_Integer := 4567; -- Індекс випадкового елемента, знак якого буде змінено

  -- Масив цілих чисел для зберігання даних
  arr : array(0..number_of_cells) of Long_Long_Integer;

  -- Процедура для ініціалізації масиву даних
  procedure Init_Arr is
  begin
    -- Заповнення масиву значеннями від 1 до number_of_cells
    for i in 1..number_of_cells loop
      arr(i) := i;
    end loop;

    -- Зміна знаку випадкового елемента
    arr(index_random):=arr(index_random)*(-1);
  end Init_Arr;

  -- Функція для пошуку мінімального значення в заданому діапазоні масиву
  function part_min(start_index, finish_index : in Long_Long_Integer) return Long_Long_Integer is
    -- Змінна для зберігання знайденого мінімального значення
    min : Long_Long_Integer := arr(start_index);
  begin
    -- Перебір елементів масиву в заданому діапазоні
    for i in start_index..finish_index loop
      -- Порівняння з поточним мінімальним значенням
      if(min>arr(i)) then
        min:=arr(i);
      end if;
    end loop;

    -- Повернення знайденого мінімального значення
    return min;
  end part_min;

  -- Захищений тип для координації роботи потоків
  protected part_manager is
    -- Процедура для оновлення знайденого мінімального значення
    procedure set_part_min(min : in Long_Long_Integer);
    -- Запис для отримання знайденого мінімального значення
    entry get_min(min2 : out Long_Long_Integer);
  private
    -- Кількість завершених потоків
    tasks_count : Long_Long_Integer := 0;
    -- Змінна для зберігання мінімального значення, знайденого потоками
    min1 : Long_Long_Integer := arr(1);
  end part_manager;

  -- Тіло захищеного типу part_manager
  protected body part_manager is
    -- Оновлення знайденого мінімального значення
    procedure set_part_min(min : in Long_Long_Integer) is
    begin
      -- Перевірка, чи нове значення менше за поточне
      if (min1>min) then
        min1 :=min;
      end if;

      -- Збільшення лічильника завершених потоків
      tasks_count := tasks_count + 1;
    end set_part_min;

    -- Отримання знайденого мінімального значення, коли всі потоки завершені
    entry get_min(min2 : out Long_Long_Integer) when tasks_count = thread_num is
    begin
      min2 := min1;
    end get_min;
  end part_manager;

  -- Тип завдання для пошуку мінімального значення в діапазоні
  task type starter_thread is
    -- Запис для отримання діапазону пошуку
    entry start(start_index, finish_index : in Long_Long_Integer);
  end starter_thread;

  -- Тіло завдання starter_thread тіло потоку пошуку мінімуму
task body starter_thread is
  -- Змінна для зберігання мінімального значення, знайденого цим потоком
  min : Long_Long_Integer := 0;
  -- Змінні для діапазону пошуку індекс початку та кінця, які будуть передані цьому потоку
  start_index, finish_index : Long_Long_Integer;
begin
  -- Очікування на отримання діапазону пошуку через запис start
  accept start(start_index, finish_index : in Long_Long_Integer) do
    -- Збереження отриманого діапазону пошуку у внутрішні змінні
    starter_thread.start_index := start_index;
    starter_thread.finish_index := finish_index;
  end start;

  -- Виклик функції part_min для пошуку мінімального значення в отриманому діапазоні масиву
  min := part_min(start_index => start_index,
                  finish_index => finish_index);

  -- Оновлення глобального мінімального значення, знайденого цим потоком, за допомогою захищеного типу part_manager
  part_manager.set_part_min(min);
end starter_thread;

-- Функція для паралельного пошуку мінімального значення за допомогою кількох потоків
function parallel_sum return Long_Long_Integer is
  -- Змінна для зберігання знайденого мінімального значення
  min : Long_Long_Integer := 0;
  -- Масив для зберігання потоків пошуку мінімального значення
  thread : array(1..thread_num) of starter_thread;
  -- Розмір блоків даних для кожного потоку кількість елементів масиву, яку оброблятиме один потік
  len : Long_Long_Integer := number_of_cells / thread_num;
begin
  -- Зациклювання для запуску потоків пошуку мінімуму в усіх блоках, крім останнього
  for i in 1 .. thread_num - 1 loop
    -- Запуск потоку thread(i) для обробки блоку даних із діапазоном від (i-1)*len до i*len елементів масиву
    thread(i).start((i - 1) * len, i * len);
  end loop;

  -- Запуск останнього потоку thread(thread_num) для обробки залишкового блоку даних 
  -- від len*(thread_num-1) елемента до кінця масиву (number_of_cells)
  thread(thread_num).start(len * (thread_num - 1), number_of_cells);

  -- Отримання знайденого мінімального значення від усіх потоків через захищений тип part_manager
  part_manager.get_min(min);

  -- Повернення знайденого мінімального значення
  return min;
end parallel_sum;

-- Змінні для вимірювання часу виконання
time : Ada.Calendar.Time := Clock;
finish_time : Duration;
rezult : Long_Long_Integer;

begin
  -- Ініціалізація масиву даних заповнення масиву arr значеннями від 1 до number_of_cells
  Init_Arr;

  -- Вимірювання часу пошуку мінімального значення одним потоком
  time := Clock;
  rezult := part_min(0, number_of_cells);
  finish_time := Clock - time;

  -- Виведення результату однопотокового пошуку значення мінімуму та витрачений час
  Put_Line(rezult'img & " one thread time: " & finish_time'img & " seconds");

  -- Вимірювання часу пошуку мінімального значення кількома потоками
  time := Clock;
  rezult := parallel_sum;
  finish_time := Clock - time;

  -- Виведення результату пошуку з використанням кількох потоків значення мінімуму та витрачений час
  Put_Line(rezult'img & " more thread time: " & finish_time'img & " seconds");
end Main;


