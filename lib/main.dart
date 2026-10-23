import 'package:flutter/material.dart';
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

  Product({
    required this.id,
    required this.name,
    required this.originalPrice,
    required this.offerPrice,
    required this.discount,
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
        scaffoldBackgroundColor: const Color(0xFF121212),
        primaryColor: const Color(0xFFD4AF37),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFD4AF37),
          surface: Color(0xFF1E1E1E),
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
  final String adminPassword = "1234"; // كلمة السر للوحة التحكم

  // قائمة المنتجات الإفتراضية
  List<Product> productsList = [
    Product(
      id: '1',
      name: 'زيت عباد الشمس 1 لتر',
      originalPrice: '65 ج.م',
      offerPrice: '52 ج.م',
      discount: 'وفر 20%',
    ),
    Product(
      id: '2',
      name: 'أرز فاخر 1 كجم',
      originalPrice: '35 ج.م',
      offerPrice: '28 ج.م',
      discount: 'وفر 20%',
    ),
  ];

  final List<String> categories = [
    'الكل',
    'بقالة ومواد غذائية',
    'ألبان ومجمدات',
    'خضراوات وفواكه',
    'منظفات ورعاية شخصية',
  ];

  String selectedCategory = 'الكل';

  Future<void> _openWhatsApp(String phone, String productName) async {
    final message = Uri.encodeComponent(
        'السلام عليكم، استفسار عن عرض: $productName في هايبر الدكان (فرع كفر المصيلحة)');
    final url = Uri.parse('https://wa.me/2$phone?text=$message');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  // نافذة تسجيل الدخول للوحة الإدارة
  void _showAdminLoginDialog() {
    final passwordController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          title: const Text('لوحة التحكم - تسجيل الدخول',
              style: TextStyle(color: Color(0xFFD4AF37), fontSize: 16)),
          content: TextField(
            controller: passwordController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'أدخل كلمة السر',
              labelStyle: TextStyle(color: Colors.grey),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD4AF37)),
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
              child: const Text('دخول', style: TextStyle(color: Colors.black)),
            ),
          ],
        );
      },
    );
  }

  // لوحة التحكم لإضافة وحذف المنتجات
  void _openAdminPanel() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1E1E1E),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final nameController = TextEditingController();
            final originalPriceController = TextEditingController();
            final offerPriceController = TextEditingController();
            final discountController = TextEditingController();

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
                      '⚙️ لوحة إدارة عروض هايبر الدكان',
                      style: TextStyle(
                          color: Color(0xFFD4AF37),
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                    const Divider(color: Colors.grey),
                    const SizedBox(height: 10),
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                          labelText: 'اسم المنتج',
                          labelStyle: TextStyle(color: Colors.grey)),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: originalPriceController,
                            decoration: const InputDecoration(
                                labelText: 'السعر الأصلي (مثال: 65 ج.م)',
                                labelStyle: TextStyle(color: Colors.grey)),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: offerPriceController,
                            decoration: const InputDecoration(
                                labelText: 'سعر العرض (مثال: 52 ج.م)',
                                labelStyle: TextStyle(color: Colors.grey)),
                          ),
                        ),
                      ],
                    ),
                    TextField(
                      controller: discountController,
                      decoration: const InputDecoration(
                          labelText: 'نسبة التوفير (مثال: وفر 20%)',
                          labelStyle: TextStyle(color: Colors.grey)),
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
                                  originalPrice:
                                      originalPriceController.text.isEmpty
                                          ? ''
                                          : originalPriceController.text,
                                  offerPrice: offerPriceController.text,
                                  discount: discountController.text.isEmpty
                                      ? 'عرض خاص'
                                      : discountController.text,
                                ),
                              );
                            });
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('تمت إضافة المنتج بنجاح!')),
                            );
                          }
                        },
                        icon: const Icon(Icons.add, color: Colors.black),
                        label: const Text('إضافة العرض فوراً',
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text('المنتجات الحالية (اضغط 🗑️ للحذف):',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: productsList.length,
                      itemBuilder: (context, index) {
                        final item = productsList[index];
                        return ListTile(
                          title: Text(item.name,
                              style: const TextStyle(color: Colors.white)),
                          subtitle: Text('${item.offerPrice} - ${item.discount}',
                              style: const TextStyle(color: Color(0xFFD4AF37))),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
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
        backgroundColor: const Color(0xFF121212),
        elevation: 2,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFD4AF37), width: 1.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'هايبر الدكان',
                style: TextStyle(
                  color: Color(0xFFD4AF37),
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'كفر المصيلحة',
              style: TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.admin_panel_settings,
                color: Color(0xFFD4AF37)),
            onPressed: _showAdminLoginDialog,
          ),
          IconButton(
            icon: const Icon(Icons.phone_forwarded, color: Color(0xFF25D366)),
            onPressed: () => _openWhatsApp('01118634111', 'استفسار عام'),
          ),
        ],
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'ابحث عن العروض والمنتجات...',
                  hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                  prefixIcon:
                      const Icon(Icons.search, color: Color(0xFFD4AF37)),
                  filled: true,
                  fillColor: const Color(0xFF1E1E1E),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFD4AF37)),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 45,
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
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFFD4AF37)
                            : const Color(0xFF1E1E1E),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFD4AF37)),
                      ),
                      child: Text(
                        cat,
                        style: TextStyle(
                          color: isSelected ? Colors.black : Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: productsList.isEmpty
                  ? const Center(
                      child: Text('لا توجد عروض حالياً، أضف أول عرض!',
                          style: TextStyle(color: Colors.grey)))
                  : GridView.builder(
                      padding: const EdgeInsets.all(12),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.72,
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
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Container(
                height: 110,
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.black26,
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(12)),
                ),
                child: const Icon(Icons.shopping_bag,
                    size: 50, color: Color(0xFFD4AF37)),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD4AF37),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    discount,
                    style: const TextStyle(
                        color: Colors.black,
                        fontSize: 10,
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
                      fontSize: 13),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      offerPrice,
                      style: const TextStyle(
                          color: Color(0xFFD4AF37),
                          fontWeight: FontWeight.bold,
                          fontSize: 14),
                    ),
                    const SizedBox(width: 6),
                    if (originalPrice.isNotEmpty)
                      Text(
                        originalPrice,
                        style: const TextStyle(
                            color: Colors.grey,
                            decoration: TextDecoration.lineThrough,
                            fontSize: 11),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF25D366),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(vertical: 4),
                    ),
                    onPressed: () => _openWhatsApp('01118634111', title),
                    icon: const Icon(Icons.chat, size: 16, color: Colors.white),
                    label: const Text('اطلب الآن',
                        style: TextStyle(color: Colors.white, fontSize: 11)),
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
