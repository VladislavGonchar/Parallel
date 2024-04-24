-- Імпортуємо пакет для роботи з текстовим введенням/виведенням
with Ada.Text_IO; use Ada.Text_IO;

procedure Main is

  -- Кількість потоків
  num_thread: Integer := 3;

  -- Масив прапорців зупинки для потоків, ініціалізується значенням False
  Can_stop: array (1..num_thread) of Boolean := (others => False);

  -- Директива для атомарного доступу до масиву Can_stop
  pragma Atomic (Can_stop);

  -- Тип завдання для зупинки потоку
  task type Stoper is
    -- Вхідний пункт для запуску зупинки, приймає тривалість та ідентифікатор потоку
    entry Start_Stoper(Timer: Duration; id: Integer);
  end Stoper;

  -- Тип завдання для виконання обчислень
  task type My_threads is
    -- Вхідний пункт для запуску потоку, приймає крок та ідентифікатор потоку
    entry Start(step: Long_Long_Integer; id: Integer);
  end My_threads;

-- Тіло завдання зупинки
task body Stoper is
  -- Локальні змінні для зберігання тривалості та ідентифікатора потоку
  Timer: Duration;
  id: Integer;
begin
  -- Очікування на вхідний виклик Start_Stoper
  accept Start_Stoper(Timer: in Duration; id: in Integer) do
    Stoper.Timer := Timer;
    Stoper.id := id;
  end Start_Stoper;

  -- Затримка на задану тривалість
  delay Timer;

  -- Встановлення прапорця зупинки для потоку з відповідним ідентифікатором
  Can_stop(id) := True;
end Stoper;

-- Тіло завдання обчислень
task body My_threads is
  -- Локальні змінні для кроків, суми, лічильника та ідентифікатора потоку
  step: Long_Long_Integer;
  sum: Long_Long_Integer := 0;  -- Ініціалізація суми нулем
  count: Long_Long_Integer := 0;  -- Ініціалізація лічильника нулем
  id: Integer;

begin
  -- Очікування на вхідний виклик Start
  accept Start(step: Long_Long_Integer; id: in Integer) do
    My_threads.step := step;
    My_threads.id := id;
  end Start;

  -- Цикл обчислень, що триває до отримання сигналу зупинки
  loop
    sum := sum + count * step;
    count := count + 1;
    exit when Can_stop(id);
  end loop;

  -- Виведення результатів потоку після зупинки
  Put_Line(id'Img & " " & sum'Img & " " & count'Img);
end My_threads;

-- Масив тривалостей для кожного потоку
Timers_array: array (1..num_thread) of Standard.Duration := (10.0, 9.0, 7.0);

-- Масив об'єктів типу My_threads для потоків
Threads_array: array (1..num_thread) of My_threads;

-- Масив об'єктів типу Stoper для зупинки потоків
Stoper_array: array (1..num_thread) of Stoper;

begin
  -- Запуск потоків обчислень та зупинки
  for i in Threads_array'Range loop
    Threads_array(i).Start(2, i);
    Stoper_array(i).Start_Stoper(Timers_array(i), i);
  end loop;
end Main;
