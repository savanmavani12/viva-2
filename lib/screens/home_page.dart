import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'dart:core';
import 'package:image_picker/image_picker.dart';
import 'package:viva_2/helper/db_helper.dart';


class Homepage extends StatefulWidget {
  const Homepage({Key? key}) : super(key: key);

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  late Future getData;

  final GlobalKey<FormState> insertForm = GlobalKey<FormState>();
  final GlobalKey<FormState> updateForm = GlobalKey<FormState>();
  final ImagePicker imagePicker = ImagePicker();

  TextEditingController nameController = TextEditingController();
  TextEditingController ageController = TextEditingController();
  TextEditingController courseController = TextEditingController();

  TextEditingController upNameController = TextEditingController();
  TextEditingController upAgeController = TextEditingController();
  TextEditingController upCourseController = TextEditingController();

  String? name;
  int? age;
  String? course;
  Uint8List? image;

  String? upName;
  int? upAge;
  String? upCourse;
  Uint8List? upImage;

  @override
  void initState() {
    DBHelper.dbHelper.createDB();
    getData = DBHelper.dbHelper.fetchAllData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.orange.withOpacity(0.8),
        title: const Text(
          "Data Base",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      backgroundColor: Colors.white,
      body: FutureBuilder(
        future: getData,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                "Error : ${snapshot.error}",
                style: const TextStyle(color: Colors.redAccent, fontSize: 16),
              ),
            );
          } else if (snapshot.hasData) {
            List<Map<String, dynamic>> data = snapshot.data;
            return (data != null)
                ? ListView.builder(
                itemCount: data.length,
                itemBuilder: (context, i) {
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: (data[i]["IMAGE"] != null)
                          ? MemoryImage(data[i]["IMAGE"])
                          : null,
                      radius: 40,
                    ),
                    title: Text("${data[i]["NAME"]}"),
                    subtitle: Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("${data[i]["AGE"]}"),
                        Text("${data[i]["COURSE"]}"),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        IconButton(
                          onPressed: () {
                            setState(() {
                              upNameController.text = data[i]["NAME"];
                              upAgeController.text =
                                  data[i]["AGE"].toString();
                              upCourseController.text = data[i]["COURSE"];
                              upImage = data[i]["IMAGE"];
                            });
                            showDialog(
                                context: context,
                                builder: ((context) =>
                                    upDateData(id: data[i]["ID"])));
                          },
                          icon: const Icon(
                            Icons.edit,
                            color: Colors.blue,
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            showDialog(
                                context: context,
                                builder: ((context) =>
                                    delete(id: data[i]["ID"])));
                          },
                          icon: const Icon(
                            Icons.delete,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  );
                })
                : const Center(
              child: Text(
                "Something went to wrong Your data is Not found...",
                style: TextStyle(color: Colors.cyan, fontSize: 16),
              ),
            );
          }
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(context: context, builder: ((context) => addData()));
        },
        shape: const CircleBorder(),
        backgroundColor: Colors.orange,
        child: const Icon(
          Icons.add,
          color: Colors.white,
          size: 32,
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.blueGrey,
        shape: const CircularNotchedRectangle(),
        child: Container(
          height: 50,
        ),
      ),
    );
  }

  // data insert
  addData() {
    return AlertDialog(
      backgroundColor: Colors.white.withOpacity(0.8),
      title: const Center(
          child: Text(
            "Insert Data",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
          )),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      content: SizedBox(
        height: 400,
        child: Form(
          key: insertForm,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              InkWell(
                onTap: () async {
                  XFile? xFile = await imagePicker.pickImage(source: ImageSource.camera, imageQuality: 70);
                  image = await xFile!.readAsBytes();
                  setState(() {
                    image = image;
                  });
                },
                child: CircleAvatar(
                  radius: 60,
                  backgroundImage: (image != null) ? MemoryImage(image!) : null,
                  child: Text("Add Image"),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Expanded(
                flex: 1,
                child: TextFormField(
                  controller: nameController,
                  validator: (val) {
                    return (val!.isEmpty) ? "Enter name.." : null;
                  },
                  onSaved: (val) {
                    name = val;
                  },
                  decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      label: const Text("name"),
                      hintText: "Enter Name"),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Expanded(
                  flex: 1,
                  child: TextFormField(
                    controller: ageController,
                    keyboardType: TextInputType.number,
                    validator: (val) {
                      return (val!.isEmpty) ? "Enter age.." : null;
                    },
                    onSaved: (val) {
                      age = int.parse(val!);
                    },
                    decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        label: const Text("Age"),
                        hintText: "Enter Age"),
                  )),
              const SizedBox(
                height: 10,
              ),
              Expanded(
                  flex: 1,
                  child: TextFormField(
                    controller: courseController,
                    validator: (val) {
                      return (val!.isEmpty) ? "Enter course.." : null;
                    },
                    onSaved: (val) {
                      course = val;
                    },
                    decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        label: const Text("Course"),
                        hintText: "Enter Course"),
                  )),
              const SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      if (insertForm.currentState!.validate()) {
                        insertForm.currentState!.save();
                        int id = await DBHelper.dbHelper.insertData(
                            name: name!,
                            age: age!,
                            course: course!,
                            image: image);
                        if (id > 0) {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(const SnackBar(
                            content: Text(
                              "Data is Successfully add... ",
                              style: TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16),
                            ),
                            behavior: SnackBarBehavior.floating,
                            //backgroundColor: Colors.white,
                          ));
                        }
                        setState(() {
                          getData = DBHelper.dbHelper.fetchAllData();
                          nameController.clear();
                          ageController.clear();
                          courseController.clear();
                          name = null;
                          age = null;
                          course = null;
                          image = null;
                        });
                        Navigator.pop(context);
                      } else {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(const SnackBar(
                          content: Text(
                            "Insert operation is failed... ",
                            style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.w500,
                                fontSize: 16),
                          ),
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: Colors.white,
                        ));
                      }
                    },
                    child: const Text("Insert"),
                  ),
                  OutlinedButton(
                      onPressed: () {
                        setState(() {
                          nameController.clear();
                          ageController.clear();
                          courseController.clear();
                          name = null;
                          age = null;
                          course = null;
                          image = null;
                        });
                        Navigator.of(context).pop();
                      },
                      child: const Text("Cancel"))
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // data delete
  delete({required int id}) {
    return AlertDialog(
      backgroundColor: Colors.white.withOpacity(0.8),
      content: Container(
        height: 120,
        child: Column(
          children: [
            const Expanded(
                child: Text(
                  "You want to delete record",
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.w400),
                )),
            const SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    int item = await DBHelper.dbHelper.deleteData(id: id);
                    if (item == 1) {
                      setState(() {
                        getData = DBHelper.dbHelper.fetchAllData();
                      });
                      Navigator.pop(context);
                    }
                  },
                  child: const Text("Yes"),
                ),
                OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("No"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  upDateData({
    required int id,
  }) {
    return AlertDialog(
      backgroundColor: Colors.white.withOpacity(0.8),
      title: const Center(
          child: Text(
            "Update Data",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
          )),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      content: SizedBox(
        height: 400,
        child: Form(
          key: updateForm,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              GestureDetector(
                onTap: () async {
                  XFile? xFile = await imagePicker.pickImage(source: ImageSource.camera,imageQuality: 70);
                  upImage = await xFile!.readAsBytes();
                  setState(() {
                    upImage;
                  });
                },
                child: CircleAvatar(
                  radius: 60,
                  backgroundImage:
                  (upImage != null) ? MemoryImage(upImage!) : null,
                  child: Text("Add Image"),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Expanded(
                flex: 1,
                child: TextFormField(
                  controller: upNameController,
                  validator: (val) {
                    return (val!.isEmpty) ? "Enter name.." : null;
                  },
                  onSaved: (val) {
                    upName = val;
                  },
                  decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      label: const Text("name"),
                      hintText: "Enter Name"),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Expanded(
                  flex: 1,
                  child: TextFormField(
                    controller: upAgeController,
                    keyboardType: TextInputType.number,
                    validator: (val) {
                      return (val!.isEmpty) ? "Enter age.." : null;
                    },
                    onSaved: (val) {
                      upAge = int.parse(val!);
                    },
                    decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        label: const Text("Age"),
                        hintText: "Enter Age"),
                  )),
              const SizedBox(
                height: 10,
              ),
              Expanded(
                  flex: 1,
                  child: TextFormField(
                    controller: upCourseController,
                    validator: (val) {
                      return (val!.isEmpty) ? "Enter course.." : null;
                    },
                    onSaved: (val) {
                      upCourse = val;
                    },
                    decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        label: const Text("Course"),
                        hintText: "Enter Course"),
                  )),
              const SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      if (updateForm.currentState!.validate()) {
                        updateForm.currentState!.save();
                        int item = await DBHelper.dbHelper.updateData(
                            name: upName,
                            age: upAge,
                            course: upCourse,
                            image: upImage,
                            id: id);
                        if (item == 1) {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(const SnackBar(
                            content: Text(
                              "Data is Successfully Updated... ",
                              style: TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16),
                            ),
                            behavior: SnackBarBehavior.floating,
                            //backgroundColor: Colors.white,
                          ));
                          setState(() {
                            getData = DBHelper.dbHelper.fetchAllData();
                            upNameController.clear();
                            upAgeController.clear();
                            upCourseController.clear();
                            upName = null;
                            upAge = null;
                            upCourse = null;
                            upImage = null;
                          });
                          Navigator.pop(context);
                        }
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              "Update operation is failed... ",
                              style: TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16),
                            ),
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: Colors.white,
                          ),
                        );
                      }
                    },
                    child: const Text("Update"),
                  ),
                  OutlinedButton(
                      onPressed: () {
                        setState(() {
                          upNameController.clear();
                          upAgeController.clear();
                          upCourseController.clear();
                          upName = null;
                          upAge = null;
                          upCourse = null;
                          upImage = null;
                        });
                        Navigator.of(context).pop();
                      },
                      child: const Text("Cancel"))
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

}
