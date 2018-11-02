Процедура АвтозагрузкаРегламентное(Замер) Экспорт
	//Получить параметры задания
	РеквизитыЗадания = ОбщегоНазначения.ЗначенияРеквизитовОбъекта(Замер, "ПолныйПуть,ЗагрузкаВРеальномВремени, НачалоПериода, КонецПериода");
	РеквизитыЗадания.Вставить("Замер", Замер); 
	
	//Получить файлы для загрузки
	ФайлыДляЗагрузки = ПолучитьСписокФайлов(РеквизитыЗадания);
	 
	ЗагрузкаФайловТЖ(Замер, ФайлыДляЗагрузки);
КонецПроцедуры

// Описание
// 
// Параметры:
// 	РеквизитыЗадания - Структура, Структура - Описание
// Возвращаемое значение:
// 	СписокЗначений - Описание
Функция ПолучитьСписокФайлов(РеквизитыЗадания)
	Результат = Новый ТаблицаЗначений();
	Результат.Колонки.Добавить("ПолноеИмя", Новый ОписаниеТипов("Строка"));
	Результат.Колонки.Добавить("Процесс", Новый ОписаниеТипов("Строка"));
	Результат.Колонки.Добавить("ПроцессИД", Новый ОписаниеТипов("Строка"));
	Результат.Колонки.Добавить("ПериодФайла", Новый ОписаниеТипов("Дата"));
	
	ИспользуетсяОграничениеПериода = ЗначениеЗаполнено(РеквизитыЗадания.НачалоПериода) ИЛИ ЗначениеЗаполнено(РеквизитыЗадания.КонецПериода);
	ИмяТекущегоФайла = Формат(ТекущаяДата() + 300,"ДФ=ггММддЧЧ;"); //добавим 5 минут для надежности
	
	СписокФайлов = НайтиФайлы(РеквизитыЗадания.ПолныйПуть, "*.log", Истина);
	Для Каждого Файл из СписокФайлов Цикл
		//пропускать каталоги
		Если Файл.ЭтоКаталог() Тогда
			Продолжить;
		КонецЕсли;
		//пропускать пустые файлы
		Если Файл.Размер()<=3 Тогда
			Продолжить;
		КонецЕсли;
		//пропускать если не в периоде загрузки
		ПериодФайла = ПолучитьПериодПоИмениФайла(Файл.ИмяБезРасширения);
		Если ИспользуетсяОграничениеПериода Тогда
			Если ЗначениеЗаполнено(РеквизитыЗадания.НачалоПериода) И ПериодФайла < НачалоЧаса(РеквизитыЗадания.НачалоПериода) 
				ИЛИ ЗначениеЗаполнено(РеквизитыЗадания.КонецПериода) И ПериодФайла > НачалоЧаса(РеквизитыЗадания.КонецПериода) Тогда
				Продолжить;
			КонецЕсли;  
		КонецЕсли;
		//пропускать файл текущего периода если не загрузка в реальном времени
		Если НЕ РеквизитыЗадания.ЗагрузкаВРеальномВремени
				И Файл.ИмяБезРасширения = ИмяТекущегоФайла Тогда
			Продолжить;
		КонецЕсли;		
		//получение параметров процесса по каталогу
		//c:\v8\log\rphost_1234\   
		//          ^^^^^^^^^^^
		КаталогПроцесса = Сред(Файл.Путь, СтрДлина(РеквизитыЗадания.ПолныйПуть) + 2, СтрДлина(Файл.Путь) - СтрДлина(РеквизитыЗадания.ПолныйПуть) - 2);
		ИмяИД = СтрРазделить(КаталогПроцесса, "_"); 
		
		СостояниеЧтения = РегистрыСведений.ГраницыЧтенияДанных.ПолучитьСостояние(РеквизитыЗадания.Замер, ИмяИД[0], ИмяИД[1], ПериодФайла);
		//пропускать прочитанные
		Если СостояниеЧтения.ПрочитанПолностью Тогда
			Продолжить;
		КонецЕсли;		
		//пропускать если размер с прошного сеанса не изменился
		Если Файл.Размер() = СостояниеЧтения.РазмерФайла Тогда
			Продолжить;
		КонецЕсли;		
		
		строкарезультата = Результат.Добавить();
		строкарезультата.ПолноеИмя = Файл.ПолноеИмя;
		строкарезультата.ПериодФайла = ПериодФайла;
		строкарезультата.Процесс = ИмяИД[0];
		строкарезультата.ПроцессИд = ИмяИД[1];
	КонецЦикла;

	Результат.Сортировать("ПериодФайла");
	
	Возврат Результат;
КонецФункции

Процедура ЗагрузкаФайловТЖ(Замер, ФайлыДляЗагрузки)
	Для Каждого строкарезультата Из ФайлыДляЗагрузки Цикл
		ОбновлениеДанных.РазобратьФайл(строкарезультата.Процесс, строкарезультата.ПроцессИд, строкарезультата.ПериодФайла, строкарезультата.ПолноеИмя, Замер);
	КонецЦикла; 
КонецПроцедуры

//дата по имени файла: ГГММДДЧЧ
Функция ПолучитьПериодПоИмениФайла(ЗНАЧ ИмяБезРасширения)
	Результат = Дата(1,1,1);
	Если СтрДлина(ИмяБезРасширения)=8 Тогда
		Попытка
			Результат = Дата(2000+Число(Сред(ИмяБезРасширения,1,2)), 
								Число(Сред(ИмяБезРасширения,3,2)), 
								Число(Сред(ИмяБезРасширения,5,2)), 
								Число(Сред(ИмяБезРасширения,7,2)), 
								0, 
								0);
		Исключение
		КонецПопытки;
	КонецЕсли;	
	Возврат Результат;
КонецФункции
