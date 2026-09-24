# Quizzler

iOS-викторина на SwiftUI: смотришь на картинку, жмёшь **Да** или **Нет**, пока тикает таймер.

Пять режимов. В **рейтинге IMDb** нужно угадать, выше или ниже порога оценка фильма. В Rick and Morty, South Park, Big Mouth и Human Resources — узнать персонажа. Раунд короткий, на 20 вопросов.

<p align="center">
  <img src="Docs/game-south-park-ok.png" width="230" hspace="8" alt="Игра, South Park">
  <img src="Docs/start.png" width="230" hspace="8" alt="Главный экран">
  <img src="Docs/game-rick-and-morty.png" width="230" hspace="8" alt="Игра, Rick and Morty">
</p>
<p align="center">
  <img src="Docs/game-south-park.png" width="230" hspace="8" alt="Игра, South Park">
  <img src="Docs/game-big-mouth.png" width="230" hspace="8" alt="Игра, Big Mouth">
  <img src="Docs/game-human-resources.png" width="230" hspace="8" alt="Игра, Human Resources">
</p>
<p align="center">
  <img src="Docs/settings-records.png" width="230" hspace="8" alt="Рекорды и сложность">
  <img src="Docs/settings-preferences.png" width="230" hspace="8" alt="Тема, звуки, вибрации, язык">
</p>

## Что внутри

На старте можно продолжить незаконченную игру или выбрать режим с нуля. Если в этом режиме уже есть сохранённый раунд, приложение спросит, вернуться к нему или начать заново.

После сплэша данные сериалов уже лежат в кэше, так что дальше можно играть без сети. IMDb вообще не ходит в интернет: фильмы и постеры упакованы в приложение.

В настройках — рекорды, скорость таймера (1–10 секунд), тема, звук, вибрация и язык (русский / английский). Вибрация ещё и дрожит на последних трёх секундах вопроса. Музыка крутится только пока открыт игровой экран.

## Режимы

- **Рейтинг IMDb** — около ста фильмов, на раунд случайно берутся 20. Порог — соседнее целое к реальному рейтингу. Вопросы «больше 10» и «меньше 10» не генерируются: первое невозможно, второе почти всегда правда.
- **Rick and Morty** — персонажи с [rickandmortyapi.com](https://rickandmortyapi.com)
- **South Park** — персонажи с [spapi.dev](https://spapi.dev)
- **Big Mouth** и **Human Resources** — персонажи с Fandom Wiki

## Как запустить

Нужны Xcode 16+ и iPhone / симулятор на iOS 18.

```bash
git clone https://github.com/dpogonia/Quizzler-SUI.git
cd Quizzler-SUI
open Quizzler.xcodeproj
```

Схема **Quizzler**, Run. CocoaPods нет, пакеты подключены через SPM.

Если правишь строки в `Quizzler/Resources`, удобно иметь [SwiftGen](https://github.com/SwiftGen/SwiftGen) — он обновит `L10n`. Без него сборка тоже проходит, в репозитории уже лежит сгенерированный файл.

Свою музыку на раунд можно положить в `Quizzler/Resources/Audio/` с именем `game_music` (лучше `.mp3`).

## Как устроен код

Приложение тонкое. Общая инфраструктура — в `Packages/CoreServices` (сеть, файлы, UserDefaults). Логика квиза — в `QuizServices`. Кнопки и карточки — в `QuizUI`.

Незаконченный раунд пишется на диск при выходе из игры и при уходе в фон: режим, вопрос, счёт, таймер, картинка. Доиграли до конца — снимок стирается.

```text
Quizzler/
├── App/            сборка зависимостей
├── UI/             сплэш, меню, игра, настройки
├── Flux/           состояние раунда
├── Resources/      строки и звуки
└── Assets.xcassets постеры IMDb

Packages/
├── CoreServices
├── QuizServices
└── QuizUI
```

Скриншоты лежат в `Docs/`.
