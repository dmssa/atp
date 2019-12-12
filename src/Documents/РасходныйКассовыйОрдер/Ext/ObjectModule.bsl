﻿
Процедура ОбработкаЗаполнения(ДанныеЗаполнения, СтандартнаяОбработка)
	Если ТипЗнч(ДанныеЗаполнения) = Тип("ДокументСсылка.ЗаказПоставщику") Тогда
		// Заполнение шапки
		Договор		= ДанныеЗаполнения.Договор;
		Сумма 		= ДанныеЗаполнения.ОбщаяСтоимость;
		Контрагент 	= ДанныеЗаполнения.Поставщик;
		Заказ 		= ДанныеЗаполнения.Ссылка;
	КонецЕсли;
КонецПроцедуры

Процедура ОбработкаПроведения(Отказ, Режим)
	Движения.Хозрасчетный.Записывать = Истина;
	Движение = Движения.Хозрасчетный.Добавить();
	Движение.СчетДт = ПланыСчетов.Хозрасчетный.РасчетыПоАвансамВыданным;
	Движение.СчетКт = ПланыСчетов.Хозрасчетный.КассаОрганизации;
	Движение.Период = Дата;
	Движение.Сумма = Сумма;
	Движение.СубконтоДт[ПланыВидовХарактеристик.ВидыСубконто.Контрагент] = Контрагент;
	Движение.СубконтоДт[ПланыВидовХарактеристик.ВидыСубконто.Договор] = Договор;

КонецПроцедуры
