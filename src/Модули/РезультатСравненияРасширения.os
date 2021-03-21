///////////////////////////////////////////////////////////////////////////////
//
// Служебный модуль получения результата сравнения расширения, основной конфы и поставки
//
// (с) BIA Technologies, LLC
//
///////////////////////////////////////////////////////////////////////////////

// Сравнивает три конфигурации - Родитель, Поставка и Расширение
//
// Параметры: 
//   РодительПуть - Строка - Каталог конфигурации Родитель
//   ПоставкаПуть - Строка - Каталог конфигурации Поставка
//   РасширениеПуть - Строка - Каталог конфигурации Расширение
//   Лог - log-manager - Экземпляр класса логирования
//
// Возвращаемое значение:
//   Структура - результат сравнения
//
Функция ПолучитьРезультатСравнения(ЭтоФорматEDT, РодительПуть, ПоставкаПуть, РасширениеПуть, Лог) Экспорт

	РасширениеОписание = Новый Структура("Префикс, Типы");

	РасширениеОписание.Вставить("РодительПуть", РодительПуть);
	РасширениеОписание.Вставить("ПоставкаПуть", ПоставкаПуть);
	РасширениеОписание.Вставить("РасширениеПуть", РасширениеПуть);

	Парсер = Новый ПарсерМодулейРасширения(РасширениеПуть);

	Если ЭтоФорматEDT Тогда
		ФайлКонфигурации = ОбъединитьПути(РасширениеПуть, "Configuration\Configuration.mdo");
	Иначе
		ФайлКонфигурации = ОбъединитьПути(РасширениеПуть, "Configuration.xml");
	КонецЕсли;
	
	РасширениеОписание.Префикс = Парсер.ПрочитатьПрефиксРасширения(ФайлКонфигурации);

	// Получить переопределенные объекты (файлы xml и bsl)
	РасширениеОписание.Типы = Парсер.ПолучитьПереопределенныеОбъекты(ЭтоФорматEDT);
	Для каждого ТипРасширения Из РасширениеОписание.Типы Цикл

		Для каждого ОбъектРасширения Из ТипРасширения.Объекты Цикл

			Если ЗначениеЗаполнено(ОбъектРасширения.Тип) Тогда
				Лог.Информация(ОбъектРасширения.Тип + " - " + ОбъектРасширения.Имя);
			Иначе
				Лог.Информация(ОбъектРасширения.Имя);
			КонецЕсли;

			Для каждого МодульРасширения Из ОбъектРасширения.Модули Цикл

				ФайлМодуля = МодульРасширения.ФайлМодуля;

				Если МодульРасширения.Свойство("ФайлФормы") Тогда
					а =4 ; //удалить после отладки
				КонецЕсли;

				МетодыФайлаРасширения = Парсер.ПрочитатьМетодыМодуля(ФайлМодуля, РасширениеОписание.Префикс);

				Если МодульРасширения.Свойство("ФайлФормы") Тогда
					а =4 ;
				КонецЕсли;

				МодульРасширения.Вставить("Методы", МетодыФайлаРасширения);

				// читаем и раскладываем модуль родителя
				Парсер.ПрочитатьМетодыОсновнойКонфигурации(ФайлМодуля, МодульРасширения, РодительПуть, "Родитель");

				// читаем и раскладываем модуль поставки
				Парсер.ПрочитатьМетодыОсновнойКонфигурации(ФайлМодуля, МодульРасширения, ПоставкаПуть, "Поставка");

			КонецЦикла;

		КонецЦикла;
		
	КонецЦикла;

	Возврат РасширениеОписание;

КонецФункции
