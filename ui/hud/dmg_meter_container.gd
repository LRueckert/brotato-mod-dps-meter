class_name DmgMeterContainer
extends VBoxContainer

export (PackedScene) var element_scene = null

func set_elements(elements: Array, index: int, replace: bool = true)->void :
	if replace:
		clear_elements()

	for element in elements:
		add_element(element, index)


func clear_elements()->void :
	for n in get_children():
		remove_child(n)
		n.queue_free()


func add_element(element: WeaponData, index: int)->void :
	var instance = element_scene.instance()
	add_child(instance)
	instance.set_element(element, index)


func trigger_element_updates()->void :
	for n in get_children():
		n.trigger_update()
