
with Ada.Text_IO; use Ada.Text_IO;

procedure Main is


  num_thread: Integer := 3;


  Can_stop: array (1..num_thread) of Boolean := (others => False);


  pragma Atomic (Can_stop);


  task type Stoper is

    entry Start_Stoper(Timer: Duration; id: Integer);
  end Stoper;


  task type My_threads is

    entry Start(step: Long_Long_Integer; id: Integer);
  end My_threads;


task body Stoper is

  Timer: Duration;
  id: Integer;
begin

  accept Start_Stoper(Timer: in Duration; id: in Integer) do
    Stoper.Timer := Timer;
    Stoper.id := id;
  end Start_Stoper;


  delay Timer;


  Can_stop(id) := True;
end Stoper;


task body My_threads is

  step: Long_Long_Integer;


  id: Integer;

begin

  accept Start(step: Long_Long_Integer; id: in Integer) do
    My_threads.step := step;
    My_threads.id := id;
  end Start;


  loop
    sum := sum + count * step;
    count := count + 1;
    exit when Can_stop(id);
  end loop;


  Put_Line(id'Img & " " & sum'Img & " " & count'Img);
end My_threads;


Timers_array: array (1..num_thread) of Standard.Duration := (10.0, 9.0, 7.0);


Threads_array: array (1..num_thread) of My_threads;


Stoper_array: array (1..num_thread) of Stoper;

begin

  for i in Threads_array'Range loop
    Threads_array(i).Start(2, i);
    Stoper_array(i).Start_Stoper(Timers_array(i), i);
  end loop;
end Main;
