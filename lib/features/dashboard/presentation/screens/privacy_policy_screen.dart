import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy & Permissions (প্রাইভেসি ও অনুমতি)'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'আমাদের প্রাইভেসি পলিসি ও ডেটা সুরক্ষা',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.deepPurple),
            ),
            const SizedBox(height: 12),
            const Text(
              'MS Smart Tools অ্যাপটি আপনার গোপনীয়তা ও ডেটা সুরক্ষাকে সর্বোচ্চ অগ্রাধিকার দেয়। নিচে আমাদের ডেটা হ্যান্ডলিং এবং পারমিশন পলিসি বিস্তারিত দেওয়া হলো:',
              style: TextStyle(fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 24),

            _buildSectionCard(
              title: '১. ডেটা স্টোরেজ (Local vs Cloud)',
              icon: Icons.storage,
              content:
                  '• লোকাল ডেটা (Local Data): আপনার সমস্ত ব্যক্তিগত হিসাব, স্ক্যান করা ডকুমেন্ট, শপিং লিস্ট এবং ফাইন্যান্স ডেটা সম্পূর্ণভাবে আপনার ডিভাইসের লোকাল এনক্রিপ্টেড ডাটাবেসে (Hive) সংরক্ষিত থাকে।\n• ক্লাউড ডেটা (Cloud Data): আমাদের কোনো ক্লাউড সার্ভারে আপনার কোনো ব্যক্তিগত ডেটা বা ডকুমেন্ট আপলোড করা হয় না। অ্যাপটি সম্পূর্ণ অফলাইন-প্রাইভেসি বজায় রেখে কাজ করে।',
            ),

            const SizedBox(height: 16),

            _buildSectionCard(
              title: '২. পারমিশন পলিসি (Permissions)',
              icon: Icons.security,
              content:
                  'অ্যাপ ইনস্টল করার সঙ্গে সঙ্গে কোনো সেন্সিটিভ পারমিশন চাওয়া হয় না। শুধুমাত্র যখন আপনি নির্দিষ্ট ফিচার ব্যবহার করবেন, তখনই অনুমতি চাওয়া হবে:\n\n'
                  '• ক্যামেরা (Camera): QR Scanner বা Document Scanner ব্যবহার করার সময় ক্যামেরার অনুমতি চাওয়া হয়।\n'
                  '• ফটো/গ্যালারি (Gallery / Photos): গ্যালারি থেকে ছবি বা ডকুমেন্ট সিলেক্ট করার সময় অনুমতি চাওয়া হয়।\n'
                  '• অপ্রয়োজনীয় ব্রড স্টোরেজ পারমিশন এড়িয়ে চলা হয়েছে।',
            ),

            const SizedBox(height: 16),

            _buildSectionCard(
              title: '৩. ডেটা এক্সপোর্ট ও ডিলিট (Export & Delete)',
              icon: Icons.download_done,
              content:
                  '• ডেটা এক্সপোর্ট: ব্যবহারকারী চাইলে ফাইন্যান্স বা অন্যান্য ডেটা JSON বা CSV ফরম্যাটে এক্সপোর্ট করতে পারবেন।\n'
                  '• ডেটা ডিলিট: ব্যবহারকারী যেকোনো সময় ট্র্যাশ থেকে বা স্থায়ীভাবে নিজের ডেটা মুছে ফেলতে পারবেন বা রিসেট করতে পারবেন।',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({required String title, required IconData icon, required String content}) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.deepPurple),
                const SizedBox(width: 10),
                Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 12),
            Text(content, style: TextStyle(fontSize: 13, height: 1.5, color: Colors.grey.shade700)),
          ],
        ),
      ),
    );
  }
}
