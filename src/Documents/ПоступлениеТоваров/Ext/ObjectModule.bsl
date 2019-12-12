﻿
Процедура ОбработкаЗаполнения(ДанныеЗаполнения, СтандартнаяОбработка)
	Если ТипЗнч(ДанныеЗаполнения) = Тип("ДокументСсылка.ЗаказПоставщику") Тогда
		// Заполнение шапки
		Договор	  = ДанныеЗаполнения.Договор;
		Поставщик = ДанныеЗаполнения.Поставщик;
		Склад     = ДанныеЗаполнения.Склад;
		Заказ     = ДанныеЗаполнения.Ссылка;
		Для Каждого ТекСтрокаТовары Из ДанныеЗаполнения.Товары Цикл
			НоваяСтрока = Товары.Добавить();
			НоваяСтрока.Количество      = ТекСтрокаТовары.Количество;
			НоваяСтрока.Номенклатура    = ТекСтрокаТовары.Номенклатура;			
			НоваяСтрока.Характеристика  = ТекСтрокаТовары.Характеристика;
			НоваяСтрока.Стоимость       = ТекСтрокаТовары.Стоимость;
			НоваяСтрока.ЦенаПоступления = ТекСтрокаТовары.ЦенаПоступления;
		КонецЦикла;
	КонецЕсли;
КонецПроцедуры

Процедура ОбработкаПроведения(Отказ, Режим)	

	Если Склад = Справочники.Склады.ПустаяСсылка() Тогда
		Склад = Константы.СкладПоУмолчанию.Получить();
		ЭтотОбъект.Записать();
	КонецЕсли;
	
    Запрос = Новый Запрос;
    Запрос.МенеджерВременныхТаблиц = Новый МенеджерВременныхТаблиц;
    Запрос.Текст = 
        "ВЫБРАТЬ
        |   ПоступлениеТоваровТовары.Номенклатура КАК Номенклатура,
        |   ПоступлениеТоваровТовары.ЦенаПоступления КАК ЦенаПоступления,
        |   ПоступлениеТоваровТовары.Стоимость КАК Стоимость,
        |   ПоступлениеТоваровТовары.Количество КАК Количество,
        |   ПоступлениеТоваровТовары.Характеристика КАК Характеристика
        |ПОМЕСТИТЬ ТабТовары
        |ИЗ
        |   Документ.ПоступлениеТоваров.Товары КАК ПоступлениеТоваровТовары
        |ГДЕ
        |   ПоступлениеТоваровТовары.Ссылка = &Ссылка
        |;
        |
        |////////////////////////////////////////////////////////////////////////////////
        |ВЫБРАТЬ
        |   ТабТовары.Номенклатура КАК Номенклатура,
        |   СРЕДНЕЕ(ТабТовары.ЦенаПоступления) КАК ЦенаПоступления,
        |   СУММА(ТабТовары.Количество) КАК Количество,
        |   СУММА(ТабТовары.Стоимость) КАК Стоимость
        |ИЗ
        |   ТабТовары КАК ТабТовары
        |
        |СГРУППИРОВАТЬ ПО
        |   ТабТовары.Номенклатура";
    
    Запрос.УстановитьПараметр("Ссылка", Ссылка);
    
    РезультатЗапроса       = Запрос.Выполнить();

    ВыборкаДетальныеЗаписи = РезультатЗапроса.Выбрать();
    
	Движения.ЦеныПоставщиков.Записывать = Истина;
    Движения.ОбъемыЗакупок.Записывать = Истина;
	Пока ВыборкаДетальныеЗаписи.Следующий() Цикл
        // регистр ЦеныПоставщиков
		Движение = Движения.ЦеныПоставщиков.Добавить();
		Движение.Период       = Дата;
		Движение.Номенклатура = ВыборкаДетальныеЗаписи.Номенклатура;
		Движение.Поставщик    = Поставщик;
		Движение.Цена         = ВыборкаДетальныеЗаписи.ЦенаПоступления;
	
        // регистр ОбъемыЗакупок 
//		Если ВыборкаДетальныеЗаписи.Номенклатура.ВидНоменклатуры <> Перечисления.ВидНоменклатуры.Услуга ТОГДА
			Движение = Движения.ОбъемыЗакупок.Добавить();
			Движение.Период       = Дата;
			Движение.Склады       = Склад;
			Движение.Номенклатура = ВыборкаДетальныеЗаписи.Номенклатура;
			Движение.Стоимость    = ВыборкаДетальныеЗаписи.Стоимость;
			Движение.Количество   = ВыборкаДетальныеЗаписи.Количество;
			Движение.Поставщик    = Поставщик;
//		КонецЕсли;		
	КонецЦикла;
    	
	// регистр ТоварыНаСкладах Приход
    // При обращении через точку к Справочник.Номенклатура.ВидНоменклатуры
    // язык запросов 1С:Предприятия создаст неявное соединение
    // со справочником «Номенклатура»
    // https://its.1c.ru/db/metod8dev#content:2662:hdoc
    //
	Движения.ТоварыНаСкладах.Записывать = Истина;
    Запрос.Текст = "ВЫБРАТЬ
                   |    ТабТовары.Номенклатура КАК Номенклатура,
                   |    ТабТовары.Количество КАК Количество,
                   |    ТабТовары.Характеристика КАК Характеристика
                   |ИЗ
                   |    ТабТовары КАК ТабТовары
                   |        ЛЕВОЕ СОЕДИНЕНИЕ Справочник.Номенклатура КАК СпрНоменклатура
                   |        ПО ТабТовары.Номенклатура = СпрНоменклатура.Ссылка
                   |ГДЕ
                   |    СпрНоменклатура.ВидНоменклатуры <> &ВидНоменклатуры";
                   
    Запрос.УстановитьПараметр("ВидНоменклатуры",Перечисления.ВидыНоменклатуры.Услуга);
    РезультатЗапроса = Запрос.Выполнить();
    
    ВыборкаДетальныеЗаписи = РезультатЗапроса.Выбрать();
    Пока ВыборкаДетальныеЗаписи.Следующий() Цикл
        Движение = Движения.ТоварыНаСкладах.ДобавитьПриход();
        Движение.Период       = Дата;
        Движение.Номенклатура = ВыборкаДетальныеЗаписи.Номенклатура;
        Движение.ХарактеристикаНоменклатуры = ВыборкаДетальныеЗаписи.Характеристика;
        Движение.Склады       = Склад;
        Движение.Количество   = ВыборкаДетальныеЗаписи.Количество;
	КонецЦикла;

	Движения.Хозрасчетный.Записывать = Истина;
	Для Каждого ТекСтрокаТовары Из Товары Цикл
		Движение = Движения.Хозрасчетный.Добавить();
		Движение.СчетДт = ПланыСчетов.Хозрасчетный.ТоварыНаСкладах;
		Движение.СчетКт = ПланыСчетов.Хозрасчетный.РасчетыСПоставщиками;
		Движение.Период = Дата;
		Движение.Сумма = ТекСтрокаТовары.Стоимость;
		Движение.КоличествоДт = ТекСтрокаТовары.Количество;
		Движение.СубконтоДт[ПланыВидовХарактеристик.ВидыСубконто.Номенклатура] = ТекСтрокаТовары.Номенклатура;
		Движение.СубконтоДт[ПланыВидовХарактеристик.ВидыСубконто.Склад] = Склад;
		Движение.СубконтоКт[ПланыВидовХарактеристик.ВидыСубконто.Контрагент] = Поставщик;
		Движение.СубконтоКт[ПланыВидовХарактеристик.ВидыСубконто.Договор] = Договор;
	КонецЦикла;
	
	Движение = Движения.Хозрасчетный.Добавить();
	Движение.СчетДт = ПланыСчетов.Хозрасчетный.РасчетыСПоставщиками;
	Движение.СчетКт = ПланыСчетов.Хозрасчетный.РасчетыПоАвансамВыданным;
	Движение.Период = Дата;
	Движение.Сумма = ОбщаяСумма;
	Движение.СубконтоДт[ПланыВидовХарактеристик.ВидыСубконто.Контрагент] = Поставщик;
	Движение.СубконтоДт[ПланыВидовХарактеристик.ВидыСубконто.Договор] = Договор;
	Движение.СубконтоКт[ПланыВидовХарактеристик.ВидыСубконто.Контрагент] = Поставщик;
	Движение.СубконтоКт[ПланыВидовХарактеристик.ВидыСубконто.Договор] = Договор;

КонецПроцедуры

Процедура ПередЗаписью(Отказ, РежимЗаписи, РежимПроведения)
	ОбщаяСумма = Товары.Итог("Стоимость");
КонецПроцедуры
