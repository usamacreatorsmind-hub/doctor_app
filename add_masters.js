/**
 * ============================================================
 *  Doctor Appointment Management System
 *  Masters Patch Script
 *  - qualification_master
 *  - specialization_master
 *
 *  Run: node add_masters.js
 * ============================================================
 */

const { initializeApp, cert } = require('firebase-admin/app');
const { getFirestore, Timestamp } = require('firebase-admin/firestore');
const serviceAccount = require("./serviceAccountKey.json");

try {
  initializeApp({
    credential: cert(serviceAccount)
  });
} catch (e) {
  // Already initialized
}

const db = getFirestore();
const now = Timestamp.now();


// ============================================================
//  qualification_master
//  Path: qualification_master/{qualificationId}
//  Fields: qualificationId, name, status, createdAt
// ============================================================
const qualifications = [
  // ── Allopathy ──
  { id: "qual_001", name: "MBBS"              },
  { id: "qual_002", name: "MD"                },
  { id: "qual_003", name: "MS"                },
  { id: "qual_004", name: "DM"                },
  { id: "qual_005", name: "MCh"               },
  { id: "qual_006", name: "DNB"               },
  { id: "qual_007", name: "FCPS"              },
  { id: "qual_008", name: "MRCP"              },
  { id: "qual_009", name: "FRCS"              },
  { id: "qual_010", name: "PhD (Medical)"     },
  { id: "qual_011", name: "Diploma (Medical)" },
  // ── Ayurveda ──
  { id: "qual_012", name: "BAMS"              },
  { id: "qual_013", name: "MD (Ayurveda)"     },
  { id: "qual_014", name: "MS (Ayurveda)"     },
  // ── Homeopathy ──
  { id: "qual_015", name: "BHMS"              },
  { id: "qual_016", name: "MD (Homeopathy)"   },
  // ── Unani ──
  { id: "qual_017", name: "BUMS"              },
  // ── Dental ──
  { id: "qual_018", name: "BDS"               },
  { id: "qual_019", name: "MDS"               },
  // ── Physiotherapy ──
  { id: "qual_020", name: "BPT"               },
  { id: "qual_021", name: "MPT"               },
  // ── Nursing ──
  { id: "qual_022", name: "GNM"               },
  { id: "qual_023", name: "B.Sc Nursing"      },
  { id: "qual_024", name: "M.Sc Nursing"      },
  // ── Pharmacy ──
  { id: "qual_025", name: "B.Pharm"           },
  { id: "qual_026", name: "Pharm.D"           },
  // ── Siddha ──
  { id: "qual_027", name: "BSMS"              },
  // ── Naturopathy ──
  { id: "qual_028", name: "BNYS"              },
  // ── Other ──
  { id: "qual_029", name: "Fellowship"        },
  { id: "qual_030", name: "Other"             },
];

// ============================================================
//  specialization_master
//  Path: specialization_master/{specializationId}
//  Fields: specializationId, name, status, createdAt
// ============================================================
const specializations = [
  { id: "spec_001", name: "Cardiology"          },
  { id: "spec_002", name: "ENT"                 },
  { id: "spec_003", name: "General Medicine"    },
  { id: "spec_004", name: "Orthopedics"         },
  { id: "spec_005", name: "Dermatology"         },
  { id: "spec_006", name: "Gynecology"          },
  { id: "spec_007", name: "Pediatrics"          },
  { id: "spec_008", name: "Neurology"           },
  { id: "spec_009", name: "Ophthalmology"       },
  { id: "spec_010", name: "Pulmonology"         },
  { id: "spec_011", name: "Endocrinology"       },
  { id: "spec_012", name: "Psychiatry"          },
  { id: "spec_013", name: "Urology"             },
  { id: "spec_014", name: "Dentistry"           },
  { id: "spec_015", name: "Pediatric ENT"       },
  { id: "spec_016", name: "Gastroenterology"    },
  { id: "spec_017", name: "Nephrology"          },
  { id: "spec_018", name: "Oncology"            },
  { id: "spec_019", name: "Rheumatology"        },
  { id: "spec_020", name: "Hematology"          },
  { id: "spec_021", name: "Physiotherapy"       },
  { id: "spec_022", name: "Radiology"           },
  { id: "spec_023", name: "Anesthesiology"      },
  { id: "spec_024", name: "Plastic Surgery"     },
  { id: "spec_025", name: "Ayurveda"            },
  { id: "spec_026", name: "Homeopathy"          },
  { id: "spec_027", name: "Unani"               },
  { id: "spec_028", name: "Naturopathy"         },
  { id: "spec_029", name: "Nutrition & Dietetics"},
  { id: "spec_030", name: "Other"               },
];

// ============================================================
//  HELPER
// ============================================================
async function seedMaster(collectionName, items, idField) {
  // Purge
  const existing = await db.collection(collectionName).get();
  if (!existing.empty) {
    const batch = db.batch();
    existing.docs.forEach((d) => batch.delete(d.ref));
    await batch.commit();
    console.log(`   🗑️  ${collectionName} → ${existing.size} old docs deleted`);
  }

  // Insert
  const batch = db.batch();
  for (const item of items) {
    batch.set(
      db.collection(collectionName).doc(item.id),
      {
        [idField]: item.id,
        name:      item.name,
        status:    "active",
        createdAt: now,
      }
    );
  }
  await batch.commit();
  console.log(`   ✅ ${collectionName} → ${items.length} docs inserted`);

  // Print list
  items.forEach((item) => console.log(`      ${item.id} → ${item.name}`));
  console.log();
}

// ============================================================
//  MAIN
// ============================================================
async function main() {
  console.log("🚀 Adding Masters — qualification + specialization");
  console.log("=".repeat(52));

  console.log("\n📚 qualification_master:");
  await seedMaster("qualification_master", qualifications, "qualificationId");

  console.log("🏥 specialization_master:");
  await seedMaster("specialization_master", specializations, "specializationId");

  console.log("=".repeat(52));
  console.log("🎉 Both masters added successfully!\n");
  console.log("Flutter mein use karo:");
  console.log("  db.collection('qualification_master').where('status', isEqualTo: 'active').get()");
  console.log("  db.collection('specialization_master').where('status', isEqualTo: 'active').get()");
  console.log();
  process.exit(0);
}

main().catch((e) => {
  console.error("❌ Error:", e.message);
  process.exit(1);
});
