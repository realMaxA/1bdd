//----------------------------------------------------------
//This Source Code Form is subject to the terms of the
//Mozilla Public License, v.2.0. If a copy of the MPL
//was not distributed with this file, You can obtain one
//at http://mozilla.org/MPL/2.0/.
//----------------------------------------------------------

//////////////////////////////////////////////////////////////////
//
// Объект-помощник для генерации файла шагов для Gherkin-спецификаций
//
//////////////////////////////////////////////////////////////////

#Использовать logos
#Использовать asserts
#Использовать tempfiles

Перем Лог;
Перем ЧитательГеркин;

Перем ВозможныеТипыШагов;
Перем ВозможныеКлючиПараметров;
Перем ПредставленияТиповПараметров;
Перем РегулярныеВыражения;

////////////////////////////////////////////////////////////////////
//{ Программный интерфейс

// возвращает массив созданных файлов шагов
Функция СгенерироватьФайлыШагов(Знач ФайлФичи, Знач ФайлБиблиотек = Неопределено, Знач ИскатьВПодкаталогах = Истина) Экспорт
	НаборБиблиотечныхШагов = ПолучитьНаборБиблиотечныхШагов(ФайлБиблиотек);
	Лог.Отладка("Найдено библиотечных шагов: %1 шт.", 
				?(ЗначениеЗаполнено(НаборБиблиотечныхШагов), НаборБиблиотечныхШагов.Количество(), "0"));

	РезМассивФайлов = Новый Массив;
	Если ФайлФичи.ЭтоКаталог() Тогда
		Лог.Информация("Подготовка к генерации шагов в каталоге " + ФайлФичи.ПолноеИмя);
		МассивФайлов = НайтиФайлы(ФайлФичи.ПолноеИмя, "*.feature", ИскатьВПодкаталогах);

		НаборРезультатовВыполнения = Новый Массив;
		Для каждого ФайлФичи Из МассивФайлов Цикл
			Если ФайлФичи.ЭтоКаталог() Тогда
				ВызватьИсключение "Нашли каталог вместо файла-фичи " + ФайлФичи.ПолноеИмя;
			КонецЕсли;
			РезМассивФайлов.Добавить(СоздатьФайлРеализацииШагов(ФайлФичи, НаборБиблиотечныхШагов));
		КонецЦикла;
	Иначе
		РезМассивФайлов.Добавить(СоздатьФайлРеализацииШагов(ФайлФичи, НаборБиблиотечныхШагов));
	КонецЕсли;
	
	Возврат РезМассивФайлов;
КонецФункции

// Возвращает имя лога 1bdd
//
//  Возвращаемое значение:
//   Строка - имя лога
Функция ИмяЛога() Экспорт
	Возврат "bdd";
КонецФункции

//}

////////////////////////////////////////////////////////////////////
//{ Реализация

Функция СоздатьФайлРеализацииШагов(Знач ФайлФичи, Знач НаборБиблиотечныхШагов)
	Лог.Отладка("Подготовка к генерации шагов спецификации %1", ФайлФичи.ПолноеИмя);
	Ожидаем.Что(ФайлФичи, "Ожидали, что файл фичи будет передан как файл, а это не так").ИмеетТип("Файл");

	РезультатыРазбора = ЧитательГеркин.ПрочитатьФайлСценария(ФайлФичи);
	ДеревоФич = РезультатыРазбора.ДеревоФич;
	Ожидаем.Что(ДеревоФич, "Ожидали, что дерево фич будет передано как дерево значений, а это не так")
			.ИмеетТип("ДеревоЗначений");

	ФайлШагов = ПолучитьФайлШагов(ФайлФичи);
	
	НаборШаговФичи = Новый Структура;
	ПолучитьНаборШаговФичи(ДеревоФич.Строки[0], НаборБиблиотечныхШагов, НаборШаговФичи, ФайлШагов);
	
	Если ЗначениеЗаполнено(НаборШаговФичи) Тогда

		Если Не ФайлШагов.Существует() Тогда
			ПодготовитьКаталогФайловШагов(ФайлФичи, ФайлШагов);
		КонецЕсли;

		ЗаполнитьФайлШагов(ФайлФичи, ДеревоФич, ФайлШагов, НаборШаговФичи);
	Иначе
		ФайлШагов = Неопределено;
		Лог.Информация("Не найдено шагов фичи, которые нет в существующих файлах-шагов.");
	КонецЕсли;

	Возврат ФайлШагов;
КонецФункции

// возвращает Неопределено, если не найдено, или соответствие, где ключ - имя шага, значение - объект-исполнитель шага (os-скрипт)
Функция ПолучитьНаборБиблиотечныхШагов(Знач ФайлБиблиотек)

	//TODO подумать о замене на промежуточный класс, который собирает информацию о шагах в исполнителях
	ИсполнительБДД = Новый ИсполнительБДД;
	Набор = ИсполнительБДД.ПолучитьНаборБиблиотечныхШагов(ФайлБиблиотек);
	ОсвободитьОбъект(ИсполнительБДД);
	Возврат Набор;
КонецФункции // ПолучитьНабор()

Процедура ПодготовитьКаталогФайловШагов(Знач ФайлФичи, Знач ФайлШагов)
	КаталогШагов = Новый Файл(ФайлШагов.Путь);
	Если Не КаталогШагов.Существует() Тогда
		Лог.Отладка("Каталог шагов не существует. Создаю новый. %1", КаталогШагов.ПолноеИмя);
		СоздатьКаталог(КаталогШагов.ПолноеИмя);
	Иначе
		Лог.Отладка("Каталог шагов уже существует. %1", КаталогШагов.ПолноеИмя);
	КонецЕсли;

КонецПроцедуры

Процедура ЗаполнитьФайлШагов(Знач ФайлФичи, ДеревоФич, Знач ФайлШагов, НаборШаговФичи)
	ЭтоПервичнаяГенерация = Не ФайлШагов.Существует();

	Если ЭтоПервичнаяГенерация Тогда
		Лог.Информация("Начинаю генерацию шагов для спецификации " + ФайлФичи.ПолноеИмя);
	Иначе
		Лог.Информация("Выполняю перегенерацию шагов для спецификации " + ФайлФичи.ПолноеИмя);
	КонецЕсли;

	Буфер = Новый Массив;

	ОписаниеЗаписываемогоФайла = Новый Структура;
	ОписаниеЗаписываемогоФайла.Вставить("Буфер", Буфер);
	ОписаниеЗаписываемогоФайла.Вставить("ФайлШагов", ФайлШагов);
	ОписаниеЗаписываемогоФайла.Вставить("ЭтоПервичнаяГенерация", ЭтоПервичнаяГенерация);

	ТаблицаМодуляШагов = Неопределено;
	НаборМетодовМодуляШагов = Неопределено;
	Если Не ЭтоПервичнаяГенерация Тогда
		ТаблицаМодуляШагов = ПрочитатьФайлВТаблицуМодуляШагов(ФайлШагов);
		НаборМетодовМодуляШагов = ПолучитьЭкспортныеМетоды(ТаблицаМодуляШагов);
	КонецЕсли;
	ОписаниеЗаписываемогоФайла.Вставить("ТаблицаМодуляШагов", ТаблицаМодуляШагов);
	ОписаниеЗаписываемогоФайла.Вставить("НаборМетодовМодуляШагов", НаборМетодовМодуляШагов);

	Если ЭтоПервичнаяГенерация Тогда
		ЗаписатьПеременныеВТелоФайлаШагов(Буфер);
	КонецЕсли;

	ЗаписатьОписанияШаговВФайлШагов(ОписаниеЗаписываемогоФайла, НаборШаговФичи);
	ЗаписатьОписанияХуковВФайлШагов(ЧитательГеркин.ВозможныеХуки().ПередЗапускомСценария, 
			"Процедура выполняется перед запуском каждого сценария", ОписаниеЗаписываемогоФайла);
	
	ЗаписатьОписанияХуковВФайлШагов(ЧитательГеркин.ВозможныеХуки().ПослеЗапускаСценария, 
			"Процедура выполняется после завершения каждого сценария", ОписаниеЗаписываемогоФайла);

	Если Не ЭтоПервичнаяГенерация Тогда
		ЗаписатьМетодыВФайл(ТаблицаМодуляШагов, НаборМетодовМодуляШагов, Буфер);
		Буфер.Добавить("");
	КонецЕсли;

	Для каждого ОписаниеИсполнителяШагов Из НаборШаговФичи Цикл
		НормализованныйАдресШага = ОписаниеИсполнителяШагов.Ключ;
		ПервыйУзелСТакимАдресом = ОписаниеИсполнителяШагов.Значение;
		АдресШага = ПервыйУзелСТакимАдресом.АдресШага;
		Лог.Отладка("Перед записью шага, адрес %1, тело %2", АдресШага, ПервыйУзелСТакимАдресом.Тело);
		ЗаписатьШаг(АдресШага, ПервыйУзелСТакимАдресом, ОписаниеЗаписываемогоФайла);
	КонецЦикла;

	Если Не ЭтоПервичнаяГенерация Тогда
		ЗаписатьОставшеесяТелоВФайл(ТаблицаМодуляШагов, НаборМетодовМодуляШагов, Буфер);
	КонецЕсли;

	МоиВременныеФайлы = Новый МенеджерВременныхФайлов;
	НовыйФайл = Новый Файл(МоиВременныеФайлы.СоздатьФайл("os"));
	ЗаписатьБуферВФайл(Буфер, НовыйФайл);

	КопироватьФайл(НовыйФайл.ПолноеИмя, ФайлШагов.ПолноеИмя);
	
	МоиВременныеФайлы.УдалитьФайл(НовыйФайл.ПолноеИмя);

	Лог.Информация("Генерация завершена.");
КонецПроцедуры

Функция ПрочитатьФайлВТаблицуМодуляШагов(ФайлШагов)
	Если Не ФайлШагов.Существует() Тогда
		ВызватьИсключение "Файл исполнителя шагов не найден." + ФайлШагов.ПолноеИмя;
	КонецЕсли;

	Рез = Новый ТаблицаЗначений;
	Рез.Колонки.Добавить("Строка");

	ЧтениеТекста = Новый ЧтениеТекста;
	ЧтениеТекста.Открыть(ФайлШагов.ПолноеИмя, "UTF-8");

	Строка = ЧтениеТекста.ПрочитатьСтроку();
	Пока Строка <> Неопределено Цикл

		НоваяСтрока        = Рез.Добавить();
		НоваяСтрока.Строка    = Строка;

		Строка = ЧтениеТекста.ПрочитатьСтроку();
	КонецЦикла;

	ЧтениеТекста.Закрыть();

	Возврат Рез;
КонецФункции

Функция ПолучитьЭкспортныеМетоды(ТаблицаМодуляШагов)
	ТаблицаМетодов = Новый ТаблицаЗначений;
	ТаблицаМетодов.Колонки.Добавить("ИмяМетода");
	ТаблицаМетодов.Колонки.Добавить("НормализованноеИмяМетода");
	ТаблицаМетодов.Колонки.Добавить("НомерСтрокиНачала");
	ТаблицаМетодов.Колонки.Добавить("НомерСтрокиБлокаДоМетода");
	ТаблицаМетодов.Колонки.Добавить("НомерСтрокиКонец");

	КонецПредыдущегоБлока = 0;
	КонецПоследнегоМетода = -1;
	Для Счетчик = 0 По ТаблицаМодуляШагов.Количество() - 1 Цикл
		Строка = ТаблицаМодуляШагов[Счетчик].Строка;
		КоллекцияСовпадений = РегулярныеВыражения.НачалоЭкспортногоМетода.НайтиСовпадения(Строка);
		Если КоллекцияСовпадений.Количество() = 0 Тогда
			Продолжить;
		КонецЕсли;

		НоваяСтрокаОписанияМетода = ТаблицаМетодов.Добавить();
		ИмяМетода = КоллекцияСовпадений[0].Группы[2].Значение;
		НоваяСтрокаОписанияМетода.ИмяМетода = ИмяМетода;
		НоваяСтрокаОписанияМетода.НормализованноеИмяМетода = ЧитательГеркин.НормализоватьАдресШага(ИмяМетода);
		НоваяСтрокаОписанияМетода.НомерСтрокиНачала = Счетчик;
		НоваяСтрокаОписанияМетода.НомерСтрокиБлокаДоМетода = КонецПредыдущегоБлока;

		Пока Истина Цикл
			Счетчик = Счетчик + 1;
			Если Счетчик >= ТаблицаМодуляШагов.Количество() Тогда
				Прервать;
			КонецЕсли;
			Строка = ТаблицаМодуляШагов[Счетчик].Строка;
			КоллекцияСовпадений = РегулярныеВыражения.КонецМетода.НайтиСовпадения(Строка);
			Если КоллекцияСовпадений.Количество() = 0 Тогда
				Продолжить;
			КонецЕсли;

			НоваяСтрокаОписанияМетода.НомерСтрокиКонец = Счетчик;

			КонецПоследнегоМетода = Счетчик;
			КонецПредыдущегоБлока = Счетчик + 1;
			Прервать;
		КонецЦикла;

	КонецЦикла;
	ТаблицаМетодов.Индексы.Добавить("НормализованноеИмяМетода");
	
	Для каждого Строка Из ТаблицаМетодов Цикл
		Лог.Отладка("Получили имя экспортного метода в файле шагов <%1>", Строка.ИмяМетода);
	КонецЦикла;
	Возврат ТаблицаМетодов;
КонецФункции // ПолучитьЭкспортныеМетоды(ТаблицаМодуляШагов)

Процедура ЗаписатьПеременныеВТелоФайлаШагов(Буфер)
	Буфер.Добавить("// Реализация шагов BDD-фич/сценариев c помощью фреймворка https://github.com/artbear/1bdd");
	Буфер.Добавить("");
	Буфер.Добавить("Перем БДД; //контекст фреймворка 1bdd");
	Буфер.Добавить("");
КонецПроцедуры

Процедура ЗаписатьОписанияШаговВФайлШагов(ОписаниеЗаписываемогоФайла, ЗНач НаборШаговФичи)
	Буфер = ОписаниеЗаписываемогоФайла.Буфер;
	ЭтоПервичнаяГенерация = ОписаниеЗаписываемогоФайла.ЭтоПервичнаяГенерация;
	ТаблицаМодуляШагов = ОписаниеЗаписываемогоФайла.ТаблицаМодуляШагов;
	НаборМетодовМодуляШагов = ОписаниеЗаписываемогоФайла.НаборМетодовМодуляШагов;
	ФайлШагов = ОписаниеЗаписываемогоФайла.ФайлШагов;

	ИмяСпецМетода = ЧитательГеркин.НаименованиеФункцииПолученияСпискаШагов();
	Если Не ЭтоПервичнаяГенерация Тогда
		НормализованныйАдресШага = ЧитательГеркин.НормализоватьАдресШага(ИмяСпецМетода);
		ОписаниеМетода = НаборМетодовМодуляШагов.Найти(НормализованныйАдресШага, "НормализованноеИмяМетода");
		Если ОписаниеМетода = Неопределено Тогда
			ВызватьИсключение СтрШаблон("Не найден метод %2 для файла шагов <%1>", ФайлШагов.ПолноеИмя, ИмяСпецМетода);
		КонецЕсли;
		ВывестиВБуферСтрокиТаблицы(Буфер, ТаблицаМодуляШагов, ОписаниеМетода.НомерСтрокиБлокаДоМетода, 
				ОписаниеМетода.НомерСтрокиНачала - 1);
	Иначе
		Буфер.Добавить("// Метод выдает список шагов, реализованных в данном файле-шагов");
	КонецЕсли;

	Буфер.Добавить(СтрШаблон("Функция %1(КонтекстФреймворкаBDD) Экспорт", ИмяСпецМетода));
	Буфер.Добавить(Символы.Таб + "БДД = КонтекстФреймворкаBDD;");
	Буфер.Добавить("");
	Буфер.Добавить(Символы.Таб + "ВсеШаги = Новый Массив;");
	Буфер.Добавить("");

	ЗаписатьКодОписанияШаговВБуфер(Буфер, НаборШаговФичи);

	Буфер.Добавить("");
	Буфер.Добавить(Символы.Таб + "Возврат ВсеШаги;");
	Буфер.Добавить("КонецФункции");

	Если ЭтоПервичнаяГенерация Тогда
		Буфер.Добавить("");
		Буфер.Добавить("// Реализация шагов");
		Буфер.Добавить("");
	КонецЕсли;

КонецПроцедуры

Процедура ЗаписатьОписанияХуковВФайлШагов(Знач ОписаниеХука, Знач КомментарийДляХука, ОписаниеЗаписываемогоФайла) //, ЗНач НаборШаговФичи)
	Буфер = ОписаниеЗаписываемогоФайла.Буфер;
	ЭтоПервичнаяГенерация = ОписаниеЗаписываемогоФайла.ЭтоПервичнаяГенерация;
	ТаблицаМодуляШагов = ОписаниеЗаписываемогоФайла.ТаблицаМодуляШагов;
	НаборМетодовМодуляШагов = ОписаниеЗаписываемогоФайла.НаборМетодовМодуляШагов;
	ФайлШагов = ОписаниеЗаписываемогоФайла.ФайлШагов;

	АдресХука = ОписаниеХука.АдресШага;

	Если Не ЭтоПервичнаяГенерация Тогда
		ОписаниеМетода = НаборМетодовМодуляШагов.Найти(АдресХука, "НормализованноеИмяМетода");
		Если ОписаниеМетода <> Неопределено Тогда
			ВывестиВБуферСтрокиТаблицы(Буфер, ТаблицаМодуляШагов, ОписаниеМетода.НомерСтрокиБлокаДоМетода, 
					ОписаниеМетода.НомерСтрокиНачала - 1);
		Иначе
			Возврат;
		КонецЕсли;
	КонецЕсли;
	Буфер.Добавить(СтрШаблон("// %1", КомментарийДляХука));

	Буфер.Добавить(СтрШаблон("Процедура %1(Знач Узел) Экспорт", АдресХука));
	Буфер.Добавить(Символы.Таб);
	Буфер.Добавить("КонецПроцедуры");
	Буфер.Добавить("");

КонецПроцедуры

Процедура ВывестиВБуферСтрокиТаблицы(Буфер, ТаблицаМодуляШагов, Начало, Окончание)
	Для Счетчик = Начало По Окончание Цикл
		Строка = ТаблицаМодуляШагов[Счетчик].Строка;
		Буфер.Добавить(Строка);
	КонецЦикла;
КонецПроцедуры

Процедура ЗаписатьМетодыВФайл(ТаблицаМодуляШагов, НаборМетодовМодуляШагов, Буфер)
	АдресФункцииПолученияСпискаШагов = ЧитательГеркин.НормализоватьАдресШага(
			ЧитательГеркин.НаименованиеФункцииПолученияСпискаШагов());

	Для каждого ОписаниеМетода Из НаборМетодовМодуляШагов Цикл
		Если ОписаниеМетода.НормализованноеИмяМетода = АдресФункцииПолученияСпискаШагов Тогда
			Продолжить;
		КонецЕсли;

		ВывестиВБуферСтрокиТаблицы(Буфер, ТаблицаМодуляШагов, ОписаниеМетода.НомерСтрокиБлокаДоМетода, 
				ОписаниеМетода.НомерСтрокиКонец);
	КонецЦикла;
КонецПроцедуры

Процедура ЗаписатьОставшеесяТелоВФайл(ТаблицаМодуляШагов, НаборМетодовМодуляШагов, Буфер)
	Ожидаем.Что(НаборМетодовМодуляШагов.Количество(), 
			"Ожидали, что НаборМетодовМодуляШагов имеет количество > 0, а это не так")
			.Больше(0);

	ПоследняяСтрока = НаборМетодовМодуляШагов[НаборМетодовМодуляШагов.Количество() - 1];
	ВывестиВБуферСтрокиТаблицы(Буфер, ТаблицаМодуляШагов, ПоследняяСтрока.НомерСтрокиКонец + 1, 
			ТаблицаМодуляШагов.Количество() - 1);
КонецПроцедуры

Процедура ЗаписатьБуферВФайл(Буфер, ФайлДляЗаписи)
	Попытка
		ЗаписьФайла = Новый ЗаписьТекста(ФайлДляЗаписи.ПолноеИмя, "utf-8");

		Для каждого Строка Из Буфер Цикл
			ЗаписьФайла.ЗаписатьСтроку(Строка);
			Лог.Отладка("Записываю в файл шагов ----- %1", Строка);
		КонецЦикла;

		ЗаписьФайла.Закрыть();
	Исключение
		ОсвободитьОбъект(ЗаписьФайла);
		ВызватьИсключение;
	КонецПопытки;
КонецПроцедуры

Процедура ПолучитьНаборШаговФичи(Знач Узел, Знач НаборБиблиотечныхШагов, НаборШаговФичи, Знач ФайлШагов)
	Лог.Отладка("ПолучитьНаборШаговФичи Обхожу узел %1, %2, <%3>, АдресШага %4",
			Узел.ТипШага, Узел.Лексема, Узел.Тело, Узел.АдресШага);

	Если Узел.ТипШага = ВозможныеТипыШагов.Шаг Тогда
		АдресШага = Узел.АдресШага;
		НормализованныйАдресШага = ЧитательГеркин.НормализоватьАдресШага(АдресШага);
		
		ОписаниеИсполнителяШагов = Неопределено;
		ШагИзБиблиотеки = ЗначениеЗаполнено(НаборБиблиотечныхШагов) 
						И НаборБиблиотечныхШагов.Свойство(НормализованныйАдресШага, ОписаниеИсполнителяШагов);

		Если ШагИзБиблиотеки Тогда
			ШагИзБиблиотеки = ОписаниеИсполнителяШагов.Файл.ПолноеИмя <> ФайлШагов.ПолноеИмя;
		КонецЕсли;
		
		Если Не ШагИзБиблиотеки И Не НаборШаговФичи.Свойство(НормализованныйАдресШага) Тогда
			НаборШаговФичи.Вставить(НормализованныйАдресШага, Узел);
			Лог.Отладка("Нашел адрес шага для вставки в файл шагов: %1, %2, <%3>",
					АдресШага, Узел.Лексема, Узел.Тело);
		КонецЕсли;
	КонецЕсли;

	Для Каждого СтрокаДерева Из Узел.Строки Цикл
		ПолучитьНаборШаговФичи(СтрокаДерева, НаборБиблиотечныхШагов, НаборШаговФичи, ФайлШагов);
	КонецЦикла;

КонецПроцедуры // ПолучитьНаборШаговФичи(РезультатыРазбора)

Процедура ЗаписатьКодОписанияШаговВБуфер(Буфер, Знач НаборШаговФичи)

	Для каждого ОписаниеШага Из НаборШаговФичи Цикл
		НормализованныйАдресШага = ОписаниеШага.Ключ;
		УзелШага = ОписаниеШага.Значение;
		АдресШага = УзелШага.АдресШага;
		Буфер.Добавить(Символы.Таб + "ВсеШаги.Добавить(""" + АдресШага + """);");
		Лог.Отладка("ЗаписатьКодОписанияШаговВБуфер - В НаборШаговФичи добавляю шаг с адресом %1, тело %2", 
				АдресШага, УзелШага.Тело);
	КонецЦикла;

КонецПроцедуры

Процедура ЗаписатьШаг(ЗНач ИмяМетода, Знач Узел, ОписаниеЗаписываемогоФайла)
	Лог.Отладка("Записываю шаг <%1>", ИмяМетода);

	Буфер = ОписаниеЗаписываемогоФайла.Буфер;
	ЭтоПервичнаяГенерация = ОписаниеЗаписываемогоФайла.ЭтоПервичнаяГенерация;
	НаборМетодовМодуляШагов = ОписаниеЗаписываемогоФайла.НаборМетодовМодуляШагов;

	АдресШага = ЧитательГеркин.НормализоватьАдресШага(ИмяМетода);

	Если Не ЭтоПервичнаяГенерация Тогда
		ОписаниеМетода = НаборМетодовМодуляШагов.Найти(АдресШага, "НормализованноеИмяМетода");
		Если ОписаниеМетода <> Неопределено Тогда
			Возврат;
		КонецЕсли;
	КонецЕсли;
	Лог.Отладка("Адрес шага <%1>", АдресШага);

	СтрокаПараметров = ПолучитьСтрокуПараметров(Узел.Параметры);

	Тело = Узел.Тело;
	Для Счетчик = 1 По СтрЧислоСтрок(Тело) Цикл
		Строка = СтрПолучитьСтроку(Тело, Счетчик);
		СтрокаДляЗаписи = СтрШаблон("//%1", Строка);
		Лог.Отладка("СтрокаДляЗаписи <%1>", СтрокаДляЗаписи);
		Буфер.Добавить(СтрокаДляЗаписи);
	КонецЦикла;

	ШаблонЗаписи = "%1 %2(%3) %4";
	СтрокаДляЗаписи = СтрШаблон(ШаблонЗаписи, "Процедура", ИмяМетода, СтрокаПараметров, "Экспорт");
	Лог.Отладка("СтрокаДляЗаписи <%1>", СтрокаДляЗаписи);
	Буфер.Добавить(СтрокаДляЗаписи);

	ШаблонЗаписи = "%1ВызватьИсключение Новый ИнформацияОбОшибке(""Шаг <%3> не реализован"", ""%2"");";
	СтрокаДляЗаписи = СтрШаблон(ШаблонЗаписи, Символы.Таб, 
		ЧитательГеркин.ПараметрИсключенияДляЕщеНеРеализованногоШага(), ИмяМетода);

	Лог.Отладка("СтрокаДляЗаписи <%1>", СтрокаДляЗаписи);
	Буфер.Добавить(СтрокаДляЗаписи);

	СтрокаДляЗаписи = "КонецПроцедуры";
	Лог.Отладка("СтрокаДляЗаписи <%1>%2", СтрокаДляЗаписи, Символы.ПС);
	Буфер.Добавить(СтрокаДляЗаписи);
	Буфер.Добавить("");

КонецПроцедуры

Функция ПолучитьСтрокуПараметров(Знач Параметры)
	СтрокаПараметров = "";
	Если ЗначениеЗаполнено(Параметры) Тогда
		Номер = 1;
		Для Каждого ОписаниеПараметра Из Параметры Цикл
			Лог.Отладка("ОписаниеПараметра.Тип %1", ОписаниеПараметра.Тип);
			ПредставлениеПараметра = ПолучитьПредставлениеПараметра(ОписаниеПараметра, Номер);
			СтрокаПараметров = СтрШаблон("%1Знач %2, ", СтрокаПараметров, ПредставлениеПараметра);
			Номер = Номер + 1;
		КонецЦикла;
		СтрокаПараметров = Лев(СтрокаПараметров, СтрДлина(СтрокаПараметров) - 2);
	КонецЕсли;
	Возврат СтрокаПараметров;
КонецФункции // ПолучитьСтрокуПараметров()

Функция ПолучитьПредставлениеПараметра(ОписаниеПараметра, Номер)
	ПредставлениеПараметра = ПредставленияТиповПараметров[ОписаниеПараметра.Тип] + Номер;
	Возврат ПредставлениеПараметра;
КонецФункции // ПолучитьПредставлениеПараметра(ОписаниеПараметра, Номер)

Функция ПолучитьФайлШагов(ФайлФичи)
	Возврат Новый Файл(ОбъединитьПути(ФайлФичи.Путь, "step_definitions", ФайлФичи.ИмяБезРасширения+ ".os"));
КонецФункции // ПолучитьФайлШагов()
//}

Функция Инициализация()
	Лог = Логирование.ПолучитьЛог(ИмяЛога());

	ЧитательГеркин = Новый ЧитательГеркин;

	ДопЛог = Логирование.ПолучитьЛог(ЧитательГеркин.ИмяЛога());
	ДопЛог.УстановитьУровень(Лог.Уровень());

	ВозможныеТипыШагов = ЧитательГеркин.ВозможныеТипыШагов();
	ВозможныеКлючиПараметров = ЧитательГеркин.ВозможныеКлючиПараметров();
	ПредставленияТиповПараметров = ВозможныеПредставленияТиповПараметров();

	РегулярныеВыражения = СоздатьРегулярныеВыражения();
КонецФункции

Функция ВозможныеПредставленияТиповПараметров()
	Рез = Новый Соответствие;
	Рез.Вставить(ВозможныеКлючиПараметров.Строка, "ПарамСтрока");
	Рез.Вставить(ВозможныеКлючиПараметров.Число, "ПарамЧисло");
	Рез.Вставить(ВозможныеКлючиПараметров.Дата, "ПарамДата");
	Рез.Вставить(ВозможныеКлючиПараметров.ПараметрДляТаблицы, "Парам");
	Рез.Вставить(ВозможныеКлючиПараметров.Таблица, "ПарамТаблица");
	Возврат Рез;
КонецФункции // ВозможныеПредставленияТиповПараметров()

Функция СоздатьРегулярныеВыражения()
	Рез = Новый Структура;
	Рез.Вставить("НачалоЭкспортногоМетода", 
			Новый РегулярноеВыражение("^\s*(Функция|Процедура)\s+([_\w\dа-яё]+)\s*\(.+(Экспорт)+"));

	Рез.Вставить("КонецМетода", Новый РегулярноеВыражение("^\s*(КонецФункции|КонецПроцедуры)"));

	ИмяСпецМетода = ЧитательГеркин.НаименованиеФункцииПолученияСпискаШагов();
	Рез.Вставить("ФункцияПолучитьСписокШагов", 
		Новый РегулярноеВыражение(СтрШаблон("^\s*Функция\s+%1\s*\(.+Экспорт", ИмяСпецМетода)));

	Возврат Новый ФиксированнаяСтруктура(Рез);
КонецФункции
// }

///////////////////////////////////////////////////////////////////
// Точка входа

Инициализация();
