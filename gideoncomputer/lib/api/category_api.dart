import "package:supabase_flutter/supabase_flutter.dart";
import '../model/category/category_model.dart';

class CategoryAPI {
  final supabase = Supabase.instance.client;

  Future<List<CategoryModel>> fetchAllCategory() async {
    final response = await supabase.from('categories').select();
    print("RAW CATEGORY RESPONSE: $response");

    return (response as List).map((e) => CategoryModel.fromJson(e)).toList();
  }
}
