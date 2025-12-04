import 'package:flutter/material.dart';

class LeadCardWidget extends StatelessWidget {
  final String logoPath;
  final String companyName;
  final String email;
  final String contactName;
  final String phone;
  final String status;
  final String lastInteraction;
  final int position;

  const LeadCardWidget({
    super.key,
    required this.logoPath,
    required this.companyName,
    required this.email,
    required this.contactName,
    required this.phone,
    required this.status,
    required this.lastInteraction,
    required this.position,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // ========================= CARD ============================
        Container(
          margin: const EdgeInsets.only(left: 36, top: 16),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.07),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ================= ROW TOPO (EMPRESA + POSIÇÃO) ===================
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Nome + Email alinhados com margem para compensar a logo fora do card
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        companyName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        email,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),

                  // Posição (#1 #2 #3)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0D65F2),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Text(
                      "#$position",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // ===================== CONTATO (Nome + Telefone) ======================
              Text(
                contactName,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),

              Text(phone, style: const TextStyle(fontSize: 13)),

              const SizedBox(height: 16),

              // ===================== STATUS ======================
              Text("Status – $status", style: const TextStyle(fontSize: 13)),

              Text(
                "Última interação: $lastInteraction",
                style: const TextStyle(fontSize: 13),
              ),

              const SizedBox(height: 16),

              // ======================= DETALHES ======================
              GestureDetector(
                onTap: () {},
                child: const Text(
                  "Detalhes do cliente",
                  style: TextStyle(
                    color: Color(0xFF0D65F2),
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),

        // ====================== LOGO FLOATING ==========================
        Positioned(
          left: 0,
          top: 32,
          child: Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            padding: const EdgeInsets.all(10),
            child: Image.asset(logoPath, fit: BoxFit.contain),
          ),
        ),
      ],
    );
  }
}
