# encoding: utf-8
# language: ru

Функционал: Выполнение библиотечных шагов
	Как Разработчик
	Я Хочу чтобы файл фичи успешно выполнялся, даже если нет собственных шагов

Сценарий: Библиотечные шаги находятся в одном файле

	Когда я подготовил тестовый каталог для фич
	И установил тестовый каталог как текущий
	И я подготовил специальную тестовую фичу "СтруктураСценария"
	И я подставил файл шагов с уже реализованными шагами для фичи "СтруктураСценария"
	И я создал файл фичи "ФичаБезШагов" с текстом
	"""
		# language: ru

		Функционал: Библиотечные шаги

		Сценарий: Использование шагов из другой фичи

			Когда я передаю параметр "Минимальный"
			Тогда я получаю параметр "Минимальный"
	"""
  И я запустил выполнение фичи "ФичаБезШагов" с передачей параметра "-require СтруктураСценария.feature"
	Тогда проверка поведения фичи "ФичаБезШагов" закончилась с кодом возврата 0

Сценарий: Библиотечные шаги находятся в каталоге

	Когда я подготовил тестовый каталог для фич
	И установил тестовый каталог как текущий
	И я создал еще один каталог "lib"
	И установил каталог "lib" как текущий
	И я подготовил специальную тестовую фичу "СтруктураСценария"
	И я подставил файл шагов с уже реализованными шагами для фичи "СтруктураСценария"
	И установил тестовый каталог как текущий
	И я создал файл фичи "ФичаБезШагов" с текстом
	"""
		# language: ru

		Функционал: Библиотечные шаги

		Сценарий: Использование шагов из другой фичи

			Когда я передаю параметр "Минимальный"
			Тогда я получаю параметр "Минимальный"
	"""
  И я запустил выполнение фичи "ФичаБезШагов" с передачей параметра "-require lib"
	Тогда проверка поведения фичи "ФичаБезШагов" закончилась с кодом возврата 0

Сценарий: Автоматическая загрузка всех шагов как библиотечных из каталога фичи

	Когда я подготовил тестовый каталог для фич
	И установил тестовый каталог как текущий
	И я подготовил специальную тестовую фичу "СтруктураСценария"
	И я подставил файл шагов с уже реализованными шагами для фичи "СтруктураСценария"
	И я создал файл фичи "ФичаБезШагов" с текстом
	"""
		# language: ru

		Функционал: Библиотечные шаги

		Сценарий: Использование шагов из другой фичи

			Когда я передаю параметр "Минимальный"
			Тогда я получаю параметр "Минимальный"
	"""
  И я запустил выполнение фичи "ФичаБезШагов" с передачей параметра ""
	Тогда проверка поведения фичи "ФичаБезШагов" закончилась с кодом возврата 0

Сценарий: Автоматическая загрузка всех шагов как библиотечных из подкаталогов каталога фичи

	Когда я подготовил тестовый каталог для фич
	И установил тестовый каталог как текущий
	И я создал еще один каталог "lib"
	И установил каталог "lib" как текущий
	И я подготовил специальную тестовую фичу "СтруктураСценария"
	И я подставил файл шагов с уже реализованными шагами для фичи "СтруктураСценария"
	И установил тестовый каталог как текущий
	И я создал файл фичи "ФичаБезШагов" с текстом
	"""
		# language: ru

		Функционал: Библиотечные шаги

		Сценарий: Использование шагов из другой фичи

			Когда я передаю параметр "Минимальный"
			Тогда я получаю параметр "Минимальный"
	"""
  И я запустил выполнение фичи "ФичаБезШагов" с передачей параметра ""
	Тогда проверка поведения фичи "ФичаБезШагов" закончилась с кодом возврата 0
