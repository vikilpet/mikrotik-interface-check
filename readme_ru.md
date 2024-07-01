# Скрипт проверки работоспособности интерфейса для MikroTik
![mikrotik interface check](https://user-images.githubusercontent.com/43970835/92155775-f2f5dd80-ee38-11ea-9af6-bb4f114d0029.gif)

GitHub: https://github.com/vikilpet/mikrotik-interface-check

Преимущества:
- Можно использовать для одного или нескольких интерфейсов.
- Вид интерфейса не важен.
- Пингуем несколько адресов, т.к. полагаться на один слишком ненадёжно.
- Можно запускать так часто, как хочется — быстрое реагирование на сбой.
- Простая установка — нужно лишь подправить несколько переменных.
- Работает на RouterOS 6 и 7

# Установка
Просто создаёте скрипт в `/system scripts` и правите переменные в `SETTINGS` на свой вкус. Переменные снабжены комментариями с примерами.

Добавьте задачу в планировщик с коротким интервалом, можно хоть несколько секунд.

    /system script run Check_ISP1

Для тестирования скрипта можно использовать такое правило:

    /ip firewall filter add action=drop chain=output comment=INT_CHECK_TEST \
        out-interface=ETHER1 protocol=icmp
