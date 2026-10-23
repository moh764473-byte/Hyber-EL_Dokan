import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const HyperElDokanApp());
}

class Product {
  String id;
  String name;
  String originalPrice;
  String offerPrice;
  String discount;
  String? imagePath;

  Product({
    required this.id,
    required this.name,
    required this.originalPrice,
    required this.offerPrice,
    required this.discount,
    this.imagePath,
  });
}

class HyperElDokanApp extends StatelessWidget {
  const HyperElDokanApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'هايبر الدكان',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFF0F0F0F),
        primaryColor: const Color(0xFFD4AF37),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFD4AF37),
          surface: Color(0xFF1A1A1A),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final String adminPassword = "2462024";

  List<Product> productsList = [
    Product(
      id: '1',
      name: 'زيت عباد الشمس الممتاز 1 لتر',
      originalPrice: '65 ج.م',
      offerPrice: '52 ج.م',
      discount: 'وفر 20%',
    ),
    Product(
      id: '2',
      name: 'أرز المصري الفاخر 1 كجم',
      originalPrice: '35 ج.م',
      offerPrice: '28 ج.م',
      discount: 'وفر 20%',
    ),
  ];

  final List<String> categories = [
    'الكل',
    'بقالة وعروض',
    'ألبان ومجمدات',
    'خضراوات وفواكه',
    'منظفات وعناية',
  ];

  String selectedCategory = 'الكل';

  Future<void> _openWhatsApp(String phone, String productName) async {
    final message = Uri.encodeComponent(
        'السلام عليكم، أريد طلب منتج: $productName من هايبر الدكان (فرع كفر المصيلحة)');
    final url = Uri.parse('https://wa.me/2$phone?text=$message');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  void _showAdminLoginDialog() {
    final passwordController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          title: const Row(
            children: [
              Icon(Icons.admin_panel_settings, color: Color(0xFFD4AF37)),
              SizedBox(width: 8),
              Text('لوحة الإدارة', style: TextStyle(color: Color(0xFFD4AF37), fontSize: 16)),
            ],
          ),
          content: TextField(
            controller: passwordController,
            obscureText: true,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              labelText: 'أدخل كلمة السر',
              labelStyle: TextStyle(color: Colors.grey),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFFD4AF37)),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD4AF37)),
              onPressed: () {
                if (passwordController.text == adminPassword) {
                  Navigator.pop(context);
                  _openAdminPanel();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('كلمة السر خاطئة!')),
                  );
                }
              },
              child: const Text('دخول', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  void _openAdminPanel() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1A1A1A),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final nameController = TextEditingController();
            final originalPriceController = TextEditingController();
            final offerPriceController = TextEditingController();
            final discountController = TextEditingController();
            String? pickedImagePath;

            Future<void> pickImage() async {
              try {
                final picker = ImagePicker();
                final pickedFile = await picker.pickImage(
                  source: ImageSource.gallery,
                  imageQuality: 70,
                );
                if (pickedFile != null) {
                  setModalState(() {
                    pickedImagePath = pickedFile.path;
                  });
                }
              } catch (e) {
                // تجاهل أي خطأ مؤقت
              }
            }

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                top: 20,
                left: 16,
                right: 16,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '⚙️ إضافة وتعديل عروض هايبر الدكان',
                      style: TextStyle(
                          color: Color(0xFFD4AF37),
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                    const Divider(color: Colors.grey),
                    const SizedBox(height: 10),
                    Center(
                      child: GestureDetector(
                        onTap: pickImage,
                        child: Container(
                          height: 90,
                          width: 90,
                          decoration: BoxDecoration(
                            color: Colors.black45,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFD4AF37), width: 1.5),
                          ),
                          child: pickedImagePath == null
                              ? const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.add_a_photo, color: Color(0xFFD4AF37), size: 28),
                                    SizedBox(height: 4),
                                    Text('صورة المنتج',
                                        style: TextStyle(color: Colors.grey, fontSize: 10)),
                                  ],
                                )
                              : ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.file(
                                    File(pickedImagePath!),
                                    fit: BoxFit.cover,
                                    width: 90,
                                    height: 90,
                                  ),
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: nameController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'اسم المنتج',
                        labelStyle: TextStyle(color: Colors.grey),
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: originalPriceController,
                            style: const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(
                              labelText: 'السعر قبل العرض',
                              labelStyle: TextStyle(color: Colors.grey),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: offerPriceController,
                            style: const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(
                              labelText: 'سعر العرض الحالي',
                              labelStyle: TextStyle(color: Colors.grey),
                            ),
                          ),
                        ),
                      ],
                    ),
                    TextField(
                      controller: discountController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'شريط الخصم (مثال: وفر 20%)',
                        labelStyle: TextStyle(color: Colors.grey),
                      ),
                    ),
                    const SizedBox(height: 15),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD4AF37),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: () {
                          if (nameController.text.isNotEmpty &&
                              offerPriceController.text.isNotEmpty) {
                            setState(() {
                              productsList.add(
                                Product(
                                  id: DateTime.now().toString(),
                                  name: nameController.text,
                                  originalPrice: originalPriceController.text,
                                  offerPrice: offerPriceController.text,
                                  discount: discountController.text.isEmpty
                                      ? 'عرض خاص'
                                      : discountController.text,
                                  imagePath: pickedImagePath,
                                ),
                              );
                            });
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('تمت إضافة المنتج بالصورة بنجاح!')),
                            );
                          }
                        },
                        icon: const Icon(Icons.add, color: Colors.black),
                        label: const Text('نشر العرض فوراً',
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 15)),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text('المنتجات المعروضة حالياً (للحذف):',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: productsList.length,
                      itemBuilder: (context, index) {
                        final item = productsList[index];
                        return ListTile(
                          title: Text(item.name, style: const TextStyle(color: Colors.white)),
                          subtitle: Text(item.offerPrice, style: const TextStyle(color: Color(0xFFD4AF37))),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.redAccent),
                            onPressed: () {
                              setState(() {
                                productsList.removeAt(index);
                              });
                              setModalState(() {});
                            },
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF141414),
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFD4AF37), width: 1.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'هايبر الدكان',
                style: TextStyle(
                  color: Color(0xFFD4AF37),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'كفر المصيلحة',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.admin_panel_settings, color: Color(0xFFD4AF37)),
            onPressed: _showAdminLoginDialog,
          ),
          IconButton(
            icon: const Icon(Icons.support_agent, color: Color(0xFF25D366)),
            onPressed: () => _openWhatsApp('01118634111', 'استفسار عام'),
          ),
        ],
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2A2200), Color(0xFF141414)],
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                ),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.5)),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '🔥 عروض الأسبوع الكبرى',
                    style: TextStyle(
                      color: Color(0xFFD4AF37),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'أقوى العروض والخصومات اليومية من هايبر الدكان لحد باب البيت.',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 42,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final cat = categories[index];
                  final isSelected = cat == selectedCategory;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedCategory = cat;
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 6),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFFD4AF37) : const Color(0xFF1A1A1A),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFD4AF37)),
                      ),
                      child: Text(
                        cat,
                        style: TextStyle(
                          color: isSelected ? Colors.black : Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: productsList.isEmpty
                  ? const Center(
                      child: Text('لا توجد عروض مضافة حالياً',
                          style: TextStyle(color: Colors.grey)))
                  : GridView.builder(
                      padding: const EdgeInsets.all(12),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.70,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: productsList.length,
                      itemBuilder: (context, index) {
                        final prod = productsList[index];
                        return _buildProductCard(
                          title: prod.name,
                          originalPrice: prod.originalPrice,
                          offerPrice: prod.offerPrice,
                          discount: prod.discount,
                          imagePath: prod.imagePath,
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard({
    required String title,
    required String originalPrice,
    required String offerPrice,
    required String discount,
    String? imagePath,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Container(
                height: 105,
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.black38,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                ),
                child: (imagePath == null || imagePath.isEmpty)
                    ? const Icon(Icons.shopping_basket, size: 45, color: Color(0xFFD4AF37))
                    : ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                        child: Image.file(
                          File(imagePath),
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: 105,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(Icons.shopping_basket, size: 45, color: Color(0xFFD4AF37));
                          },
                        ),
                      ),
              ),
              if (discount.isNotEmpty)
                Positioned(
                  top: 6,
                  right: 6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD4AF37),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      discount,
                      style: const TextStyle(
                          color: Colors.black,
                          fontSize: 9,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      offerPrice,
                      style: const TextStyle(
                          color: Color(0xFFD4AF37),
                          fontWeight: FontWeight.bold,
                          fontSize: 13),
                    ),
                    const SizedBox(width: 5),
                    if (originalPrice.isNotEmpty)
                      Text(
                        originalPrice,
                        style: const TextStyle(
                            color: Colors.grey,
                            decoration: TextDecoration.lineThrough,
                            fontSize: 10),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF25D366),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6)),
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      minimumSize: const Size(0, 30),
                    ),
                    onPressed: () => _openWhatsApp('01118634111', title),
                    icon: const Icon(Icons.chat, size: 14, color: Colors.white),
                    label: const Text('اطلب واتساب',
                        style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
