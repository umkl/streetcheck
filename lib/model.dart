class CheckTask {
  String name;
  bool checked;

  CheckTask(this.name, this.checked);

  CheckTask.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        checked = json['checked'];

  Map<String, dynamic> toJson() => {
        "name": name,
        "checked": checked,
      };
}
