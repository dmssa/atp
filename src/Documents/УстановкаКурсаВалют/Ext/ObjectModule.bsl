﻿
Процедура ОбработкаПроведения(Отказ, Режим)
	//{{__КОНСТРУКТОР_ДВИЖЕНИЙ_РЕГИСТРОВ
	// Данный фрагмент построен конструктором.
	// При повторном использовании конструктора, внесенные вручную изменения будут утеряны!!!

	// регистр КурсыВалют
	Движения.КурсыВалют.Записывать = Истина;
	Для Каждого ТекСтрокаКурсы Из Курсы Цикл
		Движение = Движения.КурсыВалют.Добавить();
		Движение.Период = Дата;
		Движение.Валюта = ТекСтрокаКурсы.Валюта;
		Движение.Курс   = ТекСтрокаКурсы.Курс;
	КонецЦикла;

	//}}__КОНСТРУКТОР_ДВИЖЕНИЙ_РЕГИСТРОВ
КонецПроцедуры

Процедура ПередУдалением(Отказ)
    Если Проведен Тогда
        Записать(РежимЗаписиДокумента.ОтменаПроведения);
    КонецЕсли; 
КонецПроцедуры
