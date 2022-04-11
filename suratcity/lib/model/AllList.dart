class AllList {
  final int id;
  final String valData;
  final String cate_name;
  final String subject;
  final String members;
  final String name;
  final String isSelected;

  AllList({
    this.id,
    this.valData,
    this.cate_name,
    this.subject,
    this.members,
    this.name,
    this.isSelected,
  });

  factory AllList.fromJson(Map<String, dynamic> json) {
    return AllList(
      id: int.tryParse(json['id'].toString()) ?? 0,
      valData: json['valData'] as String,
      cate_name: json['cate_name'] as String,
      subject: json['subject'] as String,
      members: json['members'] as String,
      name: json['name'] as String,
      isSelected: json['isSelected'] as String,
    );
  }
}
