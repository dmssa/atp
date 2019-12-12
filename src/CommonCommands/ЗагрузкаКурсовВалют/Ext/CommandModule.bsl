﻿
&НаКлиенте
Процедура ОбработкаКоманды(ПараметрКоманды, ПараметрыВыполненияКоманды)
    ОбработкаКомандыНаСервере();
КонецПроцедуры

// Создает и проводит документ Документы.УстановкаКурсаВалют,
// заполняя данными с сервера http://web.cbr.ru/ ,
// в соответствии с параметром Константы.СоздаватьВалютыАвтоматически
//
&НаСервере
Процедура ОбработкаКомандыНаСервере()
    Соединение = WSСсылки.КурсыВалютССайтаЦБ.СоздатьWSПрокси("http://web.cbr.ru/", "DailyInfo", "DailyInfoSoap");
    
    ТипWSПараметра  = Соединение.ФабрикаXDTO.Пакеты.Получить("http://web.cbr.ru/").Получить("GetCursOnDate");
    СегодняшняяДата = Соединение.ФабрикаXDTO.Создать(ТипWSПараметра);
    СегодняшняяДата.On_Date = ТекущаяДата(); 

    КурсыВалют = Соединение.GetCursOnDate(СегодняшняяДата);
    
    НовыйДок = Документы.УстановкаКурсаВалют.СоздатьДокумент();
    НовыйДок.Дата = ТекущаяДата();
    СоздаватьНовыеВалюты = Константы.СоздаватьВалютыАвтоматически.Получить();
    Для каждого Элемент Из КурсыВалют.GetCursOnDateResult.diffgram.ValuteData.ValuteCursOnDate Цикл
    
        НайденнаяВалюта = Справочники.Валюты.НайтиПоКоду(Элемент.Vcode);
    
    	Если СоздаватьНовыеВалюты И Не ЗначениеЗаполнено(НайденнаяВалюта) Тогда
            НоваяВалюта = Справочники.Валюты.СоздатьЭлемент();
            НоваяВалюта.Код          = Элемент.Vcode;
            НоваяВалюта.Наименование = Элемент.Vname;
            НоваяВалюта.Записать();
            НайденнаяВалюта = НоваяВалюта.Ссылка;
        КонецЕсли; 
        Если НайденнаяВалюта <> Справочники.Валюты.ПустаяСсылка() Тогда
            НоваяСтрока = НовыйДок.Курсы.Добавить();
            НоваяСтрока.Валюта = НайденнаяВалюта;   
            НоваяСтрока.Курс   = Элемент.Vcurs;
        КонецЕсли; 
    КонецЦикла;
    Попытка
        НовыйДок.Записать(РежимЗаписиДокумента.Проведение);
        Сообщить("Курс валют загружен! Создан документ "+ НовыйДок.Ссылка); 
    Исключение
        Инфо = ИнформацияОбОшибке();
        Сообщить(Инфо.Описание+" "+Инфо.Причина.Описание); 
    КонецПопытки; 
КонецПроцедуры
