﻿
Процедура ОбработкаЗаполнения(ДанныеЗаполнения, СтандартнаяОбработка)
	//{{__КОНСТРУКТОР_ВВОД_НА_ОСНОВАНИИ
	// Данный фрагмент построен конструктором.
	// При повторном использовании конструктора, внесенные вручную изменения будут утеряны!!!
	//}}__КОНСТРУКТОР_ВВОД_НА_ОСНОВАНИИ
	Если ТипЗнч(ДанныеЗаполнения) = Тип("ДокументСсылка.ЗаказКлиента") Тогда
		// Заполнение шапки
		Покупатель 	= ДанныеЗаполнения.Покупатель;
		Склад 		= ДанныеЗаполнения.Склад;
		Договор 	= ДанныеЗаполнения.Договор;
		Заказ 		= ДанныеЗаполнения.Ссылка;
		Для Каждого ТекСтрокаТовары Из ДанныеЗаполнения.Товары Цикл
			НоваяСтрока = Товары.Добавить();
			НоваяСтрока.Количество     = ТекСтрокаТовары.Количество;
			НоваяСтрока.Номенклатура   = ТекСтрокаТовары.Номенклатура;
			НоваяСтрока.Характеристика = ТекСтрокаТовары.Характеристика;
			НоваяСтрока.Стоимость      = ТекСтрокаТовары.Стоимость;
			НоваяСтрока.ЦенаРеализации = ТекСтрокаТовары.ЦенаРеализации;
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
    //  1. Создаём временную таблицу ТабТовары
    //  2. Делаем выборку для регистра ТоварыНаСкладах
    Запрос.Текст = "ВЫБРАТЬ
                   |	РеализацияТоваровТовары.Номенклатура КАК Номенклатура,
                   |	РеализацияТоваровТовары.Характеристика КАК Характеристика,
                   |	РеализацияТоваровТовары.Количество КАК Количество,
                   |	РеализацияТоваровТовары.Стоимость КАК Стоимость,
                   |	РеализацияТоваровТовары.ЦенаРеализации КАК Цена
                   |ПОМЕСТИТЬ ТабТовары
                   |ИЗ
                   |	Документ.РеализацияТоваров.Товары КАК РеализацияТоваровТовары
                   |ГДЕ
                   |	РеализацияТоваровТовары.Ссылка = &Ссылка
                   |
                   |ИНДЕКСИРОВАТЬ ПО
                   |	Номенклатура
                   |;
                   |
                   |////////////////////////////////////////////////////////////////////////////////
                   |ВЫБРАТЬ
                   |	ТабТовары.Номенклатура КАК Номенклатура,
                   |	ТабТовары.Характеристика КАК Характеристика,
                   |	ТабТовары.Количество КАК Количество,
                   |	СпрНоменклатура.ВидНоменклатуры КАК ВидНоменклатуры
                   |ИЗ
                   |	ТабТовары КАК ТабТовары
                   |		ЛЕВОЕ СОЕДИНЕНИЕ Справочник.Номенклатура КАК СпрНоменклатура
                   |		ПО ТабТовары.Номенклатура = СпрНоменклатура.Ссылка";
    
    Запрос.УстановитьПараметр("Ссылка", Ссылка);
    РезультатЗапроса = Запрос.Выполнить();
    Выборка = РезультатЗапроса.Выбрать();
    
	Движения.ТоварыНаСкладах.Записывать = Истина;
	
	Пока Выборка.Следующий() Цикл
    	// регистр ТоварыНаСкладах Расход
		Если Выборка.ВидНоменклатуры = Перечисления.ВидыНоменклатуры.Товар ТОГДА
			Движение = Движения.ТоварыНаСкладах.ДобавитьРасход();
			Движение.Период       = Дата;
			Движение.Номенклатура = Выборка.Номенклатура;
			Движение.ХарактеристикаНоменклатуры = Выборка.Характеристика;
			Движение.Склады       = Склад;
			Движение.Количество   = Выборка.Количество;
		КонецЕсли;
    КонецЦикла; 
    
    //  3. Делаем выборку для проверки остатков товаров в регистре ТоварыНаСкладах
    ПроверятьСклад = Константы.ИспользоватьНесколькоСкладов.Получить();
    Запрос.Текст = "ВЫБРАТЬ
                   |    ТоварыНаСкладахОстатки.Номенклатура КАК Номенклатура,
                   |    ТоварыНаСкладахОстатки.ХарактеристикаНоменклатуры КАК Характеристика,
                   |    ТоварыНаСкладахОстатки.КоличествоОстаток КАК КоличествоОстаток
                   |ИЗ
                   |    РегистрНакопления.ТоварыНаСкладах.Остатки(
                   |            &МоментВремени,
                   |            " + ?(ПроверятьСклад, "Склады = &Склад И ", "") + "
                   |                Номенклатура В
                   |                    (ВЫБРАТЬ
                   |                        ТабТовары.Номенклатура
                   |                    ИЗ
                   |                        ТабТовары КАК ТабТовары)) КАК ТоварыНаСкладахОстатки,
                   |    ТабТовары КАК ТабТовары
                   |ГДЕ
                   |    ТоварыНаСкладахОстатки.Номенклатура = ТабТовары.Номенклатура
                   |    И ТоварыНаСкладахОстатки.ХарактеристикаНоменклатуры = ТабТовары.Характеристика
                   |    И ТоварыНаСкладахОстатки.КоличествоОстаток < 0";
    
    Если ПроверятьСклад Тогда
        Запрос.УстановитьПараметр("Склад", Склад);
    КонецЕсли; 
    
    Движения.ТоварыНаСкладах.БлокироватьДляИзменения = Истина;
    Движения.Записать();
    
    Граница = Новый Граница(МоментВремени(), ВидГраницы.Включая);
    Запрос.УстановитьПараметр("МоментВремени", Граница);        
    
    РезультатЗапроса = Запрос.Выполнить();
    
    Выборка = РезультатЗапроса.Выбрать();
    
    Если Выборка.Количество() > 0 Тогда
        Пока Выборка.Следующий() Цикл
        	Сообщить("Недостаточно товара " 
        			+ Выборка.Номенклатура 
        			+ " с характеристикой """ 
        			+ Выборка.Характеристика + """" 
        			+ ?(ПроверятьСклад
        				, " на складе """ + Склад + """"
        				, "") 
        			+ "! Не хватает: " 
        			+ (-Выборка.КоличествоОстаток));
        КонецЦикла; 
    	//  Если товаров недостаточно - откатываем транзакцию
        Отказ = Истина;
        Возврат;
    КонецЕсли; 
    
    //  Если товаров достаточно, продолжаем проведение документа
    // 
    //  4. Делаем выборку без учёта Характеристик для регистров ЦеныПокупателей и ОбъёмыПродаж
    Запрос.Текст = "ВЫБРАТЬ
                   |    ТабТовары.Номенклатура КАК Номенклатура,
                   |    СУММА(ТабТовары.Количество) КАК Количество,
                   |    СУММА(ТабТовары.Стоимость) КАК Стоимость,
                   |    СРЕДНЕЕ(ТабТовары.Цена) КАК Цена
                   |ИЗ
                   |    ТабТовары КАК ТабТовары
                   |
                   |СГРУППИРОВАТЬ ПО
                   |    ТабТовары.Номенклатура";
        
	
	Движения.ЦеныПокупателей.Записывать = Истина;
	Движения.ОбъёмыПродаж.Записывать    = Истина;
	
	РезультатЗапроса = Запрос.Выполнить();
    Выборка = РезультатЗапроса.Выбрать();
    Пока Выборка.Следующий() Цикл
    // регистр ЦеныПокупателей
		Движение = Движения.ЦеныПокупателей.Добавить();
		Движение.Период       = Дата;
		Движение.Номенклатура = Выборка.Номенклатура;
		Движение.Покупатель   = Покупатель;
		Движение.Цена         = Выборка.Цена;
	// регистр ОбъёмыПродаж 
//		Если Выборка.Номенклатура.ВидНоменклатуры = Перечисления.ВидыНоменклатуры.Товар ТОГДА
		Движение = Движения.ОбъёмыПродаж.Добавить();
		Движение.Период       = Дата;             
		Движение.Склады       = Склад;
		Движение.Номенклатура = Выборка.Номенклатура;
		Движение.Стоимость    = Выборка.Стоимость;
		Движение.Количество   = Выборка.Количество;
		Движение.Покупатель   = Покупатель;
//		КонецЕсли;
    КонецЦикла;  

	// регистр Хозрасчетный 
	Выборка.Сбросить();

	Движения.Хозрасчетный.Записывать = Истина;
	Пока Выборка.Следующий()  Цикл
		Движение = Движения.Хозрасчетный.Добавить();
		Движение.СчетДт = ПланыСчетов.Хозрасчетный.РасчетыСПокупателями;
		Движение.СчетКт = ПланыСчетов.Хозрасчетный.Выручка;
		Движение.Период = Дата;
		Движение.Сумма = Выборка.Стоимость;//ОбщаяСумма;
		
		Движение.СубконтоДт[ПланыВидовХарактеристик.ВидыСубконто.Контрагент] = Покупатель;
		Движение.СубконтоДт[ПланыВидовХарактеристик.ВидыСубконто.Договор] = Договор;
		
		Движение.СубконтоКт[ПланыВидовХарактеристик.ВидыСубконто.Номенклатура] = Выборка.Номенклатура;
	КонецЦикла; 
КонецПроцедуры


Процедура ПередЗаписью(Отказ, РежимЗаписи, РежимПроведения)
	ОбщаяСумма = Товары.Итог("Стоимость");
КонецПроцедуры


Процедура ОбработкаПроведения1(Отказ, Режим)
	#Область ПолучениеВыборкиСебестоимости
	
	Запрос = Новый Запрос;
	Запрос.МенеджерВременныхТаблиц = Новый МенеджерВременныхТаблиц();
	// Группируем повторяющиеся значения Номенклатуры и Характеристики,
	// помещаем во временную таблицу, выгружаем для обхода значений
	// Находим Количество остатков и их цены в разрезе Номенклатуры
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	ТабЧасть.Номенклатура КАК Номенклатура,
		|	ТабЧасть.Характеристика КАК Характеристика,
		|	СУММА(ТабЧасть.Количество) КАК Количество,
		|	СУММА(ТабЧасть.Стоимость) КАК Стоимость
		|ПОМЕСТИТЬ ВТ_Товары
		|ИЗ
		|	Документ.РеализацияТоваровУслуг.Товары КАК ТабЧасть
		|ГДЕ
		|	ТабЧасть.Ссылка = &Ссылка
		|
		|СГРУППИРОВАТЬ ПО
		|	ТабЧасть.Номенклатура,
		|	ТабЧасть.Характеристика
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ РАЗЛИЧНЫЕ
		|	ВТ_Товары.Номенклатура КАК Номенклатура,
		|	ТоварыНаСкладахОстатки.Характеристика КАК Характеристика,
		|	ВТ_Товары.Стоимость КАК Стоимость,
		|	ВТ_Товары.Количество КАК Количество,
		|	ЕСТЬNULL(ТоварыНаСкладахОстатки.КоличествоОстаток * ЦеныНоменклатурыСрезПоследних.Цена, 0) КАК Сумма,
		|	ЕСТЬNULL(ТоварыНаСкладахОстатки.КоличествоОстаток, 0) КАК КоличествоОстаток
		|ИЗ
		|	ВТ_Товары КАК ВТ_Товары
		|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрНакопления.ТоварыНаСкладах.Остатки(
		|				&Дата,
		|				Номенклатура В
		|					(ВЫБРАТЬ
		|						ВТ_Товары.Номенклатура КАК Номенклатура
		|					ИЗ
		|						ВТ_Товары КАК ВТ_Товары)) КАК ТоварыНаСкладахОстатки
		|		ПО ВТ_Товары.Номенклатура = ТоварыНаСкладахОстатки.Номенклатура
		|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.ЦеныНоменклатуры.СрезПоследних(
		|				&Дата,
		|				Номенклатура В
		|						(ВЫБРАТЬ
		|							ВТ_Товары.Номенклатура КАК Номенклатура
		|						ИЗ
		|							ВТ_Товары КАК ВТ_Товары)
		|					И ВидЦены = &ВидЦены) КАК ЦеныНоменклатурыСрезПоследних
		|		ПО (ТоварыНаСкладахОстатки.Номенклатура = ЦеныНоменклатурыСрезПоследних.Номенклатура)
		|			И (ТоварыНаСкладахОстатки.Характеристика = ЦеныНоменклатурыСрезПоследних.Характеристика)
		|ИТОГИ
		|	МАКСИМУМ(Стоимость),
		|	МАКСИМУМ(Количество),
		|	СУММА(Сумма),
		|	СУММА(КоличествоОстаток)
		|ПО
		|	Номенклатура";
		
				
	Граница = Новый Граница(МоментВремени(), ВидГраницы.Включая);
	Запрос.УстановитьПараметр("Дата", Граница);
	
	Запрос.УстановитьПараметр("ВидЦены", Справочники.ВидыЦен.Закупочная);
	Запрос.УстановитьПараметр("Ссылка", Ссылка);
			
	
	
	Движения.ТоварыНаСкладах.Записывать = Истина;
	
	
	// После записи расхода в регистр ТоварыНаСкладах, 
	// если количество товаров стало 0
	// не получить информацию о себестоимости товара
	
	// Свойство: Удаление движений: удалять автоматически при отмене проведения
	// При перепроведении сохраняются записи в регистре ТоварыНаСкладах
	// Записываем пустой набор данных, чтобы учитывать товары этого движения
	// перед этим блокируем регистр ТоварыНаСкладах
	// Движения.ТоварыНаСкладах.БлокироватьДляИзменения = Истина;
	//Движения.ТоварыНаСкладах.Записать();
	
	// Свойство: Удаление движений: удалять автоматически
	// Очищаем только движения, записи в регистре удалила система 
	Движения.ТоварыНаСкладах.Очистить();
	
	
	РезультатЗапроса     = Запрос.Выполнить();
	
	

	ВыборкаСебестоимости = РезультатЗапроса.Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам);
	#КонецОбласти 
	
	#Область ПроверкаНаОтрицательныйОстаток
	
	
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	ВТ_Товары.Номенклатура КАК Номенклатура,
		|	ВТ_Товары.Характеристика КАК Характеристика,
		|	ВТ_Товары.Количество КАК Количество
		|ИЗ
		|	ВТ_Товары КАК ВТ_Товары";
	Результат_Товары = Запрос.Выполнить();
	Выборка_Товары = Результат_Товары.Выбрать();
	
	// регистр ТоварыНаСкладах Расход
	Пока Выборка_Товары.Следующий() Цикл
		Движение = Движения.ТоварыНаСкладах.ДобавитьРасход();
		Движение.Период 		= Дата;
		Движение.Номенклатура 	= Выборка_Товары.Номенклатура;
		Движение.Характеристика = Выборка_Товары.Характеристика;
		Движение.Склад 			= Склад;
		Движение.Количество 	= Выборка_Товары.Количество;
	КонецЦикла;
	
	// Записываем движения товаров, очищаем флаг Движения.ТоварыНаСкладах.БлокироватьДляИзменения
	Движения.Записать();
	
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	ТоварыНаСкладахОстатки.КоличествоОстаток КАК КоличествоОстаток,
		|	ТоварыНаСкладахОстатки.Номенклатура КАК Номенклатура,
		|	ТоварыНаСкладахОстатки.Характеристика КАК Характеристика
		|ИЗ
		|	РегистрНакопления.ТоварыНаСкладах.Остатки(
		|			&Дата,
		|			(Номенклатура, Характеристика) В
		|					(ВЫБРАТЬ
		|						ВТ_Товары.Номенклатура,
		|						ВТ_Товары.Характеристика
		|					ИЗ
		|						ВТ_Товары)
		|				И Склад = &Склад) КАК ТоварыНаСкладахОстатки
		|ГДЕ
		|	ТоварыНаСкладахОстатки.КоличествоОстаток < 0
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|УНИЧТОЖИТЬ ВТ_Товары";
	
	Запрос.УстановитьПараметр("Склад", Склад);
	РезультатЗапроса = Запрос.Выполнить();
	
	
	Если Не РезультатЗапроса.Пустой() Тогда
		ВыборкаДетальныеЗаписи = РезультатЗапроса.Выбрать();
		Пока ВыборкаДетальныеЗаписи.Следующий() Цикл
			Сообщить("Недостаточно товара " 
				+ ВыборкаДетальныеЗаписи.Номенклатура 
				+ " с характеристикой "
				+ ВыборкаДетальныеЗаписи.Характеристика
				+ " на складе "
				+ Склад
				+ "! "
				+ "Нехватает "
				+ -ВыборкаДетальныеЗаписи.КоличествоОстаток);
		КонецЦикла; 
		
		Отказ = Истина;
		Возврат;
	КонецЕсли;
	#КонецОбласти		

	// регистр Прибыль таблица Товары
	Движения.Прибыль.Записывать = Истина;
	Пока ВыборкаСебестоимости.Следующий() Цикл
		Движение = Движения.Прибыль.Добавить();
		Движение.Период = Дата;
		Движение.Номенклатура = ВыборкаСебестоимости.Номенклатура;
		
		// Себестоимость = Расчеты.РасчетСебестоимостиТовара(ТекСтрокаТовары.Номенклатура);
		Выборка = ВыборкаСебестоимости.Выбрать();
		//Пока Выборка.Следующий() Цикл
		//КонецЦикла; 
		Себестоимость = ВыборкаСебестоимости.Сумма / ВыборкаСебестоимости.КоличествоОстаток;	
		Прибыль = ВыборкаСебестоимости.Стоимость - Себестоимость * ВыборкаСебестоимости.Количество;
		
		Движение.Сумма = Прибыль;
	КонецЦикла;

	// регистр Прибыль таблица Услуги
	Для Каждого ТекСтрокаТовары Из Услуги Цикл
		Движение = Движения.Прибыль.Добавить();
		Движение.Период = Дата;
		Движение.Номенклатура = ТекСтрокаТовары.Номенклатура;
		Движение.Сумма = ТекСтрокаТовары.Стоимость;
	КонецЦикла;

КонецПроцедуры
