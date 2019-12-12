﻿//  -----   События html элементов   -----
Функция ПриНажатии(ПараметрыКомпонента, Действие = "") Экспорт
	ИмяСобытия = "ПриНажатии";
	eventName  = "click";
	Возврат ПриСобытии(ПараметрыКомпонента, Действие, ИмяСобытия, eventName);
КонецФункции

Функция ПриИзменении(ПараметрыКомпонента, Действие = "") Экспорт
	ИмяСобытия = "ПриИзменении";
	eventName  = "change";
	Возврат ПриСобытии(ПараметрыКомпонента, Действие, ИмяСобытия, eventName);
КонецФункции

//  Общая функция для событий элементов click, change и т.д.
Функция ПриСобытии(ПараметрыКомпонента, Действие, ИмяСобытия, eventName) Экспорт
	Имя = ПараметрыКомпонента._Имя;
	Если ПараметрыКомпонента.Свойство(ИмяСобытия) Тогда
		Если СвойстваКомпонента.ЭтоСвойство(ПараметрыКомпонента[ИмяСобытия]) Тогда
		    ПараметрыКомпонента[ИмяСобытия].Добавить(Действие);
		    
		    Возврат ПараметрыКомпонента[ИмяСобытия];
		Иначе
			ВызватьИсключение("Не могу записать событие " 
				+ ИмяСобытия 
				+ " в компонент " 
				+ Имя
				+ ". В свойство уже записано значение");	
		КонецЕсли; 
	КонецЕсли; 
	Событие = Компонент.Создать();
	НомерСобытия = ПараметрыКомпонента["_События"].Количество();
	
	Компонент.ЗаполнитьИзТекста(Событие, "
		| Компонент.ПослеЗагрузки." + ИмяСобытия + "_" + Имя + "=function(){
		|   const elem = Элементы." + Имя + " || document.querySelector('." + Имя + "'); 
		|   if(elem){
		|     const fn = function(event){const Событие=event;${" + ИмяСобытия + "}};
		|     elem.addEventListener('" + eventName + "', fn);
		|   }else{
		|     console.error('Событие " + ИмяСобытия + " у " + Имя + " не зарегистрировано!(Элемент не найден)');
		|   };
		| };");
	Событие[ИмяСобытия] = "_Сб_" + ИмяСобытия;
	
	ПараметрыКомпонента["_События"].Добавить(Событие);
	ПараметрыКомпонента.Вставить(ИмяСобытия, СвойстваКомпонента.Создать("Массив"));
	Если Действие <> Неопределено Тогда
	    ПараметрыКомпонента[ИмяСобытия].Добавить(Действие);
	КонецЕсли; 
	Возврат ПараметрыКомпонента[ИмяСобытия];
КонецФункции

Функция ПослеЗагрузкиКомпонента(ПрмКомпонента, Действие = "") Экспорт
	Событие = Компонент.Создать();
	НомерСобытия = ПрмКомпонента["_События"].Количество();
	Имя = ПрмКомпонента._Имя;
	
	Компонент.ЗаполнитьИзТекста(Событие, "
			|   Компонент.ПослеЗагрузки.${ПослеЗагрузкиИмя}=function(){
			|     delete Реквизиты." + Имя + "._События[" + НомерСобытия + "];
			|     ${СкриптПослеЗагрузки}
			|   };");
	Событие.ПослеЗагрузкиИмя = "ПослеЗагрузки_" + Имя;
	Событие.СкриптПослеЗагрузки = СвойстваКомпонента.Создать("Массив");
	Если Не ПустаяСтрока(Действие)  Тогда
		Событие.СкриптПослеЗагрузки.Добавить(Действие);
	КонецЕсли; 
	ПрмКомпонента["_События"].Добавить(Событие);
	Возврат Событие.СкриптПослеЗагрузки;
КонецФункции

Функция ПриКаждойЗагрузке(ПрмКомпонента, Действие = "") Экспорт	
	Событие = Компонент.Создать();
	НомерСобытия = ПрмКомпонента["_События"].Количество();
	Имя = ПрмКомпонента._Имя;
	
	Компонент.ЗаполнитьИзТекста(Событие, "
			|   Компонент.ПриКаждойЗагрузке['${ПриКаждойЗагрузкеИмя}']=function(){
			|     delete Реквизиты." + Имя + "._События[" + НомерСобытия + "];
			|     ${СкриптПриКаждойЗагрузке}
			|   };");
	Событие.ПриКаждойЗагрузкеИмя = Имя;
	Событие.СкриптПриКаждойЗагрузке = СвойстваКомпонента.Создать("Массив");
	Если Не ПустаяСтрока(Действие) Тогда
		Событие.СкриптПриКаждойЗагрузке.Добавить(Действие);
	КонецЕсли; 
	ПрмКомпонента["_События"].Добавить(Событие);
	Возврат Событие.СкриптПриКаждойЗагрузке;
КонецФункции
 
