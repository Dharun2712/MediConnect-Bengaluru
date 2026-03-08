"""
Initialize hospitals near Saveetha Engineering College in the database
Reference Point: Saveetha Engineering College, Chennai
Coordinates: 13.0285647, 80.0142324
"""

from models import db, hospitals
from datetime import datetime
import math

def calculate_distance(lat1, lon1, lat2, lon2):
    """Calculate distance between two coordinates using Haversine formula (in km)"""
    R = 6371  # Earth's radius in km
    
    lat1_rad = math.radians(lat1)
    lat2_rad = math.radians(lat2)
    dlat = math.radians(lat2 - lat1)
    dlon = math.radians(lon2 - lon1)
    
    a = math.sin(dlat/2)**2 + math.cos(lat1_rad) * math.cos(lat2_rad) * math.sin(dlon/2)**2
    c = 2 * math.atan2(math.sqrt(a), math.sqrt(1-a))
    
    return R * c

# Reference point: Saveetha Engineering College, Chennai
REFERENCE_LAT = 13.0285647
REFERENCE_LNG = 80.0142324

# Hospital data
hospitals_data = [
    {
        'id': 'saveetha_reference',
        'name': 'Saveetha Engineering College (Reference Point)',
        'lat': 13.0285647,
        'lng': 80.0142324,
        'rating': 4.8,
        'beds': 0,
        'icu': 0,
        'doctors': 0,
        'address': 'Saveetha Engineering College, Thandalam, Chennai',
        'phone': '+91-44-26801999',
        'specializations': ['Reference Point']
    },
    {
        'id': 'saveetha_medical_center',
        'name': 'Saveetha Medical Center',
        'lat': 13.0239381,
        'lng': 80.0055357,
        'rating': 4.6,
        'beds': 200,
        'icu': 25,
        'doctors': 80,
        'address': 'Saveetha Nagar, Thandalam, Chennai',
        'phone': '+91-44-26801000',
        'specializations': ['Emergency Care', '24x7 Service', 'Multi-specialty', 'Surgery', 'ICU Care']
    },
    {
        'id': 'aachi_hospital',
        'name': 'Aachi Hospital',
        'lat': 13.0405157,
        'lng': 80.0077017,
        'rating': 4.3,
        'beds': 100,
        'icu': 12,
        'doctors': 35,
        'address': 'Poonamallee, Chennai',
        'phone': '+91-44-26490001',
        'specializations': ['Emergency Care', 'General Medicine', 'Pediatrics', 'Women & Children']
    },
    {
        'id': 'shifa_medicals',
        'name': 'Shifa Medicals & SP Clinic Emergency 24hrs & Lab',
        'lat': 13.0381752,
        'lng': 80.0286376,
        'rating': 4.2,
        'beds': 60,
        'icu': 8,
        'doctors': 20,
        'address': 'Poonamallee, Chennai',
        'phone': '+91-44-26490002',
        'specializations': ['Emergency Care', '24x7 Emergency', 'Lab Services', 'General Medicine']
    },
    {
        'id': 'panimalar_medical_college',
        'name': 'Panimalar Medical College Hospital & Research Institute',
        'lat': 13.0437301,
        'lng': 80.0347024,
        'rating': 4.5,
        'beds': 300,
        'icu': 30,
        'doctors': 100,
        'address': 'Varadharajapuram, Poonamallee, Chennai',
        'phone': '+91-44-26490003',
        'specializations': ['Emergency Care', '24x7 Service', 'Multi-specialty', 'Teaching Hospital', 'ICU Care', 'Trauma Center']
    },
    {
        'id': 'hopewell_hospital',
        'name': 'Hopewell Hospital',
        'lat': 13.0318194,
        'lng': 79.9874457,
        'rating': 4.4,
        'beds': 120,
        'icu': 15,
        'doctors': 45,
        'address': 'Sriperumbudur Road, Chennai',
        'phone': '+91-44-26490004',
        'specializations': ['Emergency Care', 'Multi-specialty', 'Surgery', 'Orthopedics', '24x7 Service']
    },
    {
        'id': 'pettai_24hrs_hospital',
        'name': 'Pettai 24 Hours Hospital',
        'lat': 13.0437301,
        'lng': 80.0347024,
        'rating': 4.1,
        'beds': 80,
        'icu': 10,
        'doctors': 25,
        'address': 'Pettai, Poonamallee, Chennai',
        'phone': '+91-44-26490005',
        'specializations': ['Emergency Care', '24x7 Emergency', 'Trauma Care', 'General Medicine']
    },
    {
        'id': 'gandhi_hospital',
        'name': 'Gandhi Hospital',
        'lat': 13.0033869,
        'lng': 79.961439,
        'rating': 4.5,
        'beds': 250,
        'icu': 30,
        'doctors': 90,
        'address': 'Sriperumbudur, Chennai',
        'phone': '+91-44-26490006',
        'specializations': ['Emergency Care', '24x7 Service', 'Multi-specialty', 'Critical Care', 'ICU Care', 'Surgery']
    },
    {
        'id': 'be_well_hospitals',
        'name': 'Be Well Hospitals Poonamallee',
        'lat': 13.0288357,
        'lng': 80.1137108,
        'rating': 4.7,
        'beds': 180,
        'icu': 22,
        'doctors': 65,
        'address': 'Poonamallee, Chennai',
        'phone': '+91-44-26490007',
        'specializations': ['Emergency Care', 'General Medicine', 'Surgery', 'Maternity', 'Pediatrics']
    },
]

def init_kongu_hospitals():
    """Initialize hospitals near Saveetha Engineering College, Chennai"""
    print("\n" + "="*70)
    print("🏥 INITIALIZING HOSPITALS NEAR SAVEETHA ENGINEERING COLLEGE, CHENNAI")
    print("="*70)
    print(f"\n📍 Reference Point: Saveetha Engineering College, Chennai")
    print(f"   Coordinates: {REFERENCE_LAT}, {REFERENCE_LNG}")
    print("\n")
    
    # Clear existing hospitals (optional - comment out if you want to keep old data)
    # hospitals.delete_many({})
    # print("🗑️  Cleared existing hospitals\n")
    
    inserted_count = 0
    updated_count = 0
    
    for hosp_data in hospitals_data:
        # Calculate distance from reference point
        distance = calculate_distance(
            REFERENCE_LAT, REFERENCE_LNG,
            hosp_data['lat'], hosp_data['lng']
        )
        
        # Determine color based on distance
        if distance < 2.0:
            color_tag = "🟢 Green (Very Close)"
        elif distance < 3.0:
            color_tag = "🟡 Yellow (Close)"
        elif distance < 4.0:
            color_tag = "🟠 Orange (Moderate)"
        else:
            color_tag = "🔴 Red (Far)"
        
        # Check if hospital already exists
        existing = hospitals.find_one({"hospital_code": hosp_data['id']})
        
        hospital_doc = {
            "hospital_code": hosp_data['id'],
            "name": hosp_data['name'],
            "location": {
                "type": "Point",
                "coordinates": [hosp_data['lng'], hosp_data['lat']]  # MongoDB uses [lng, lat]
            },
            "address": hosp_data['address'],
            "phone": hosp_data['phone'],
            "emergency_phone": hosp_data['phone'],
            "specializations": hosp_data['specializations'],
            "capacity": {
                "icu_beds": hosp_data['icu'],
                "general_beds": hosp_data['beds'],
                "doctors_available": hosp_data['doctors']
            },
            "available_beds": hosp_data['beds'] - 10,  # Some beds occupied
            "rating": hosp_data['rating'],
            "distance_from_kongu": round(distance, 2),
            "status": "active",
            "verified": True,
            "updated_at": datetime.utcnow()
        }
        
        if not existing:
            hospital_doc["created_at"] = datetime.utcnow()
            hospitals.insert_one(hospital_doc)
            inserted_count += 1
            print(f"✅ Added: {hosp_data['name']}")
        else:
            hospitals.update_one(
                {"hospital_code": hosp_data['id']},
                {"$set": hospital_doc}
            )
            updated_count += 1
            print(f"🔄 Updated: {hosp_data['name']}")
        
        print(f"   📍 Location: {hosp_data['lat']}, {hosp_data['lng']}")
        print(f"   📏 Distance: {distance:.2f} km from Saveetha Engineering College")
        print(f"   🎨 Color Tag: {color_tag}")
        print(f"   ⭐ Rating: {hosp_data['rating']}")
        print(f"   🛏️  Beds: {hosp_data['beds']} | ICU: {hosp_data['icu']} | Doctors: {hosp_data['doctors']}")
        print(f"   📞 Phone: {hosp_data['phone']}")
        print()
    
    print("="*70)
    print(f"✅ Hospital Initialization Complete!")
    print(f"   📊 New hospitals added: {inserted_count}")
    print(f"   🔄 Existing hospitals updated: {updated_count}")
    print(f"   📍 Total hospitals: {len(hospitals_data)}")
    print("="*70)
    
    # Print sorted by distance
    print("\n📊 HOSPITALS SORTED BY DISTANCE FROM SAVEETHA ENGINEERING COLLEGE:")
    print("="*70)
    
    sorted_hospitals = sorted(hospitals_data, key=lambda x: calculate_distance(
        REFERENCE_LAT, REFERENCE_LNG, x['lat'], x['lng']
    ))
    
    for i, hosp in enumerate(sorted_hospitals, 1):
        distance = calculate_distance(REFERENCE_LAT, REFERENCE_LNG, hosp['lat'], hosp['lng'])
        print(f"{i}. {hosp['name']}: {distance:.2f} km")
    
    print("="*70)

if __name__ == "__main__":
    init_kongu_hospitals()
