﻿
Процедура ПриНачалеРаботыСистемы()
    
    #Область КорректировкаПараметровСистемы
    ИнициализацияСервер.Инициализация();
    #КонецОбласти    
    #Область ДЗ_7_2
    Дата = ТекущаяДата();
    Час = Час(Дата);
    
    Если      Час >= 6  И Час <= 11  Тогда
        Текст = "Доброе утро!";
    ИначеЕсли Час >= 12 И Час <= 17  Тогда
        Текст = "Добрый день!";
    ИначеЕсли Час >= 18 И Час <= 23  Тогда
        Текст = "Добрый вечер!";
    Иначе
        Текст = "Доброго времени суток!";
    КонецЕсли; 
    #КонецОбласти    
    
    Сообщить(Текст + " Приложение Автоматизация торгового предприятия приветствует Вас!");
КонецПроцедуры


