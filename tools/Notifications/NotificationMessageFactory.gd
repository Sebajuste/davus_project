class_name NotificationMessageFactory

const AmmoNotification = preload("NotificationPickUpAmmo/NotificationPickUpAmmo.tscn")
const WeaponNotification = preload("NotificationPickUpWeapon/NotificationPickUpWeapon.tscn")
const KeyNotification = preload("NotificationPickUpKey/NotificationPickUpKey.tscn")


func _init():
	pass


func create_item_notification(item: Item) -> Node:
	match item.type:
		"key":
			return KeyNotification.instance()
		"ammo":
			var ammo_type = item.properties["ammo_type"]
			var notification = AmmoNotification.instance()
			notification.type = ammo_type
			notification.message = tr("info_ammo_type") + " : " + tr("label_"+ammo_type.to_lower ())
			return notification
		"gun":
			var notification = WeaponNotification.instance()
			notification.damage = item.properties["damage"]
			notification.rate = item.properties["rate"]
			return notification
		_:
			return null
	
	return null

