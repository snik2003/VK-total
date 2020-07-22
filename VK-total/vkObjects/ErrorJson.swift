//
//  ErrorJson.swift
//  VK-total
//
//  Created by Сергей Никитин on 25.02.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import Foundation
import SwiftyJSON

class ErrorJson {
    var errorCode: Int = 0
    var errorMsg: String = ""
    
    init(json: JSON) {
        self.errorCode = json["error_code"].intValue
        self.errorMsg = json["error_msg"].stringValue
    }
    
    func showErrorMessage(controller: UIViewController) {
        switch self.errorCode {
        case 1:
            controller.showErrorMessage(title: "Неизвестная ошибка!", msg: "Попробуйте повторить запрос позже.")
        case 5:
            controller.showErrorMessage(title: "Авторизация пользователя не удалась!", msg: "Убедитесь, что Вы используете верную схему авторизации.")
        case 6:
            controller.showErrorMessage(title: "Слишком много запросов в секунду!", msg: "Попробуйте повторить запрос позже.")
        case 7:
            controller.showErrorMessage(title: "Нет прав для выполнения этого действия!", msg: "Проверьте, получены ли нужные права доступа при авторизации.")
        case 10:
            controller.showErrorMessage(title: "Внутренняя ошибка сервера!", msg: "Попробуйте повторить запрос позже.")
        case 14:
            controller.showErrorMessage(title: "Требуется ввод кода с картинки!", msg: "Проведите данное действие через полную версию сайта.")
        case 15:
            controller.showErrorMessage(title: "Доступ запрещён!", msg: "Убедитесь, что доступ к запрашиваемому контенту для текущего пользователя есть в полной версии сайта.")
        case 18:
            controller.showErrorMessage(title: "Страница удалена или заблокирована!", msg: "Страница пользователя была удалена или заблокирована.")
        case 23:
            controller.showErrorMessage(title: "Метод был выключен!", msg: "Данный метод устарел. Сообщите разработчикам приложения.")
        case 30:
            controller.showErrorMessage(title: "Профиль является приватным!", msg: "Информация, запрашиваемая о профиле, недоступна с используемым ключом доступа")
        case 100:
            controller.showErrorMessage(title: "Неверные параметры запроса!", msg: "Один из необходимых параметров был не передан или неверен. Сообщите разработчикам приложения.")
        case 113:
            controller.showErrorMessage(title: "Неверный идентификатор пользователя!", msg: "Убедитесь, что Вы используете верный идентификатор.")
        case 200:
            controller.showErrorMessage(title: "Доступ к альбому запрещён!", msg: "Убедитесь, что доступ к запрашиваемому контенту для текущего пользователя есть в полной версии сайта.")
        case 201:
            controller.showErrorMessage(title: "Доступ к аудио запрещён!", msg: "Убедитесь, что доступ к запрашиваемому контенту для текущего пользователя есть в полной версии сайта.")
        case 203:
            controller.showErrorMessage(title: "Доступ к группе запрещён!", msg: "Убедитесь, что доступ к запрашиваемому контенту для текущего пользователя есть в полной версии сайта.")
        case 300:
            controller.showErrorMessage(title: "Альбом переполнен!", msg: "Перед продолжением работы нужно удалить лишние объекты из альбома или использовать другой альбом.")
        default:
            controller.showErrorMessage(title: "Ошибка #\(self.errorCode)", msg: "\n\(self.errorMsg)\n")
        }
    }
}
