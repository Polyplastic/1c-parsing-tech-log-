#Если Сервер ИЛИ ВнешнееСоединение Тогда
	
Функция ПолучитьСостояние(Замер, Процесс, ПроцессИД, ПериодФайла) Экспорт
	Результат = Новый Структура("ПрочитаноСтрок,ПрочитанПолностью,РазмерФайла", 0, Ложь, 0);
	
	ПроцессСсылка = СправочникиСерверПовтИсп.ПолучитьПроцесс(Процесс);
	Запрос = Новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ
	|	ГраницыЧтенияДанных.ПрочитаноСтрок,
	|	ГраницыЧтенияДанных.ПрочитанПолностью,
	|	ГраницыЧтенияДанных.РазмерФайла
	|ИЗ
	|	РегистрСведений.ГраницыЧтенияДанных КАК ГраницыЧтенияДанных
	|ГДЕ
	|	ГраницыЧтенияДанных.Замер = &Замер
	|	И ГраницыЧтенияДанных.Процесс = &Процесс
	|	И ГраницыЧтенияДанных.ПроцессID = &ПроцессИд
	|	И ГраницыЧтенияДанных.ДатаФайла = &ДатаФайла";
	Запрос.УстановитьПараметр("Замер", Замер);
	Запрос.УстановитьПараметр("Процесс", ПроцессСсылка);
	Запрос.УстановитьПараметр("ПроцессИД", ПроцессИД);
	Запрос.УстановитьПараметр("ДатаФайла", ПериодФайла);
	РезультатЗапроса = Запрос.Выполнить(); 
	Если НЕ РезультатЗапроса.Пустой() Тогда
		ЗаполнитьЗначенияСвойств(Результат, РезультатЗапроса.Выгрузить()[0]);
	КонецЕсли;
	
	Возврат Результат;
КонецФункции

Процедура УстановитьСостояние(Замер, Процесс, ПроцессID, Период, ПрочитаноСтрок, ДатаНачалаЧтения, ПрочитаноРазмер) Экспорт
	
	//если дата начала чтения больше чем конец часа (запас в 5 минут) 
	//считаем что файл больше дополняться не будет
	ПрочитанПолностью = ДатаНачалаЧтения > КонецЧаса(Период) + 300;
	
	ТекущееСостояние = ПолучитьСостояние(Замер, Процесс, ПроцессID, Период);
	Если ТекущееСостояние.ПрочитаноСтрок = ПрочитаноСтрок
		И ТекущееСостояние.ПрочитанПолностью = ПрочитанПолностью Тогда
		Возврат;
	КонецЕсли;	
	
	МенеджерЗаписи = РегистрыСведений.ГраницыЧтенияДанных.СоздатьМенеджерЗаписи();
	МенеджерЗаписи.Замер = Замер;
	МенеджерЗаписи.Процесс = СправочникиСерверПовтИсп.ПолучитьПроцесс(Процесс);
	МенеджерЗаписи.ПроцессID = ПроцессID;
	МенеджерЗаписи.ДатаФайла = Период;
	МенеджерЗаписи.ПрочитаноСтрок = ПрочитаноСтрок;
	МенеджерЗаписи.ПрочитанПолностью = ПрочитанПолностью;
	МенеджерЗаписи.РазмерФайла = ПрочитаноРазмер;
	МенеджерЗаписи.Записать();		
	
КонецПроцедуры

#КонецЕсли