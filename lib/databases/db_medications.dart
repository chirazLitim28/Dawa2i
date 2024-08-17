import 'package:sqflite/sqflite.dart';
import 'dbhelper.dart';

class MedicationDB {
  static Future<List<Map<String, dynamic>>> getAllMedications(
      DateTime day) async {
    final database = await DBHelper.getDatabase();
    String formattedDay =
        "${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}";
    return database.rawQuery('''
    SELECT 
      medications.id,
      medications.name,
      medications.dose,
      medications.num_pill,
      medications.date,
      GROUP_CONCAT(medication_times.time) as times,
      GROUP_CONCAT(medication_times.taken) as takens
    FROM medications
    LEFT JOIN medication_times ON medications.id = medication_times.medication_id
    WHERE medications.date = ?
    GROUP BY medications.id
  ''', [formattedDay]);
  }

  static Future<List<Map<String, dynamic>>>
      getAllMedicationsForDisplay() async {
    final database = await DBHelper.getDatabase();
    return database.rawQuery('''
      SELECT 
        id,
        name,
        dose,
        num_pill,
        GROUP_CONCAT(DISTINCT date) as dates
      FROM medications
      GROUP BY name
    ''');
  }

  static Future insertMedication(Map<String, dynamic> data, List<String> times,
      List<String> takens) async {
    final database = await DBHelper.getDatabase();
    int medicationId = await database.insert("medications", data,
        conflictAlgorithm: ConflictAlgorithm.replace);

    if (times.isNotEmpty) {
      Batch batch = database.batch();
      for (int i = 0; i < times.length; i++) {
        batch.rawInsert(
          '''
        INSERT INTO medication_times (medication_id, time, taken) VALUES (?, ?, ?)
        ''',
          [
            medicationId,
            times[i],
            takens[i],
          ],
        );
      }
      await batch.commit(noResult: true);
    }

    if (data.containsKey('date')) {
      DateTime currentDate = DateTime.parse(data['date']);
      DateTime endDate = DateTime.now().add(Duration(days: 365));

      while (currentDate.isBefore(endDate)) {
        String formattedDate =
            "${currentDate.year}-${currentDate.month.toString().padLeft(2, '0')}-${currentDate.day.toString().padLeft(2, '0')}";

        Map<String, dynamic> newData = {
          'name': data['name'],
          'dose': data['dose'],
          'num_pill': data['num_pill'],
          'date': formattedDate,
        };

        int subsequentMedId = await database.insert("medications", newData,
            conflictAlgorithm: ConflictAlgorithm.replace);

        if (times.isNotEmpty) {
          Batch batch = database.batch();
          for (int i = 0; i < times.length; i++) {
            batch.rawInsert(
              '''
        INSERT INTO medication_times (medication_id, time, taken) VALUES (?, ?, ?)
        ''',
              [
                subsequentMedId,
                times[i],
                takens[i],
              ],
            );
          }
          await batch.commit(noResult: true);
        }

        if (currentDate.isAtSameMomentAs(DateTime.parse(data['date']))) {
          // Create the medication for the selected date as well
          int selectedMedId = await database.insert("medications", data,
              conflictAlgorithm: ConflictAlgorithm.replace);

          if (times.isNotEmpty) {
            Batch batch = database.batch();
            for (int i = 0; i < times.length; i++) {
              batch.rawInsert(
                '''
          INSERT INTO medication_times (medication_id, time, taken) VALUES (?, ?, ?)
          ''',
                [
                  selectedMedId,
                  times[i],
                  takens[i],
                ],
              );
            }
            await batch.commit(noResult: true);
          }
        }

        currentDate = currentDate.add(Duration(days: 1));
      }
    }
  }

  static Future<void> updateTakenStatus(
      int medicationId, String newStatus, String time) async {
    final database = await DBHelper.getDatabase();
    await database.rawUpdate('''
      UPDATE medication_times 
      SET taken = ? 
      WHERE medication_id = ? AND time = ?
    ''', [newStatus, medicationId, time]);
  }

  static Future deleteMedication(int id) async {
    final database = await DBHelper.getDatabase();
    database.rawQuery("""DELETE FROM medications WHERE id = ?""", [id]);
  }

  static Future<void> updateMedication(
      int id, Map<String, dynamic> newData) async {
    final database = await DBHelper.getDatabase();

    // Perform the update operation
    await database
        .update("medications", newData, where: 'id = ?', whereArgs: [id]);

    // Fetch and print the updated record
    List<Map<String, dynamic>> updatedRecords = await database.query(
      'medications',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (updatedRecords.isNotEmpty) {
      print('Updated Medication Record: ${updatedRecords.first}');
    } else {
      print('Medication with ID $id not found after update.');
    }
  }
}
