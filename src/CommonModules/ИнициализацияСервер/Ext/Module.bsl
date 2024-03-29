﻿// Общий модуль разработан для установки начальных параметров

#Область ПрограммныйИнтерфейс
// Инициализирует начальные значения констант складов
//
Процедура Инициализация() Экспорт
	ПараметрыСеанса.Инициализация = Истина;
	НесколькоСкладов = Константы.ИспользоватьНесколькоСкладов.Получить();
	ОдинСклад        = Константы.ИспользоватьОдинСклад.Получить();
	Если ОдинСклад = НесколькоСкладов Тогда
		Константы.ИспользоватьОдинСклад.Установить(НЕ НесколькоСкладов);
	КонецЕсли;
	Если Константы.СкладПоУмолчанию.Получить() = Справочники.Склады.ПустаяСсылка() Тогда
		Оптовый = Справочники.Склады.НайтиПоНаименованию("Оптовый");
		Константы.СкладПоУмолчанию.Установить(Оптовый);
	КонецЕсли;
	
	
	ПроверкиСервер.ВосстановитьЗначенияПредопределенных();
	ПараметрыСеанса.Инициализация = Ложь;
КонецПроцедуры                                                 	
#КонецОбласти