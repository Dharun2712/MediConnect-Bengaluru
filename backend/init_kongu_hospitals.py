"""
Initialize hospitals near Sree Sakthi Engineering College in the database
Reference Point: Sree Sakthi Engineering College, Coimbatore
Coordinates: 11.2219, 76.9482
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

# Reference point: Sree Sakthi Engineering College, Coimbatore
REFERENCE_LAT = 11.2219
REFERENCE_LNG = 76.9482

# Hospital data
hospitals_data = [
    {
        'id': 'ssec_reference',
        'name': 'Sree Sakthi Engineering College (Reference Point)',
        'lat': 11.2219,
        'lng': 76.9482,
        'rating': 4.8,
        'beds': 0,
        'icu': 0,
        'doctors': 0,
        'address': 'Sree Sakthi Engineering College, Coimbatore',
        'phone': '+91-4285-265500',
        'specializations': ['Reference Point']
    },
    # Nearest hospitals to Sree Sakthi Engineering College
    {
        'id': 'sowmiya_hospital',
        'name': 'Sowmiya Hospital',
        'lat': 11.237326,
        'lng': 76.9334645,
        'rating': 4.5,
        'beds': 120,
        'icu': 15,
        'doctors': 40,
        'address': 'Near Sree Sakthi Engineering College, Coimbatore',
        'phone': '+91-4285-245001',
        'specializations': ['Emergency Care', '24x7 Service', 'General Medicine', 'Surgery', 'ICU Care']
    },
    {
        'id': 'subbu_hospital',
        'name': 'Subbu Hospital',
        'lat': 11.2433146,
        'lng': 76.9562011,
        'rating': 4.3,
        'beds': 80,
        'icu': 10,
        'doctors': 30,
        'address': 'Coimbatore District, Tamil Nadu',
        'phone': '+91-4285-245002',
        'specializations': ['Emergency Care', 'General Medicine', 'Pediatrics', 'Women & Children']
    },
    {
        'id': 'savidha_hospitals',
        'name': 'Savidha Hospitals Private Limited',
        'lat': 11.2374497,
        'lng': 76.92818,
        'rating': 4.4,
        'beds': 100,
        'icu': 12,
        'doctors': 35,
        'address': 'Coimbatore, Tamil Nadu',
        'phone': '+91-4285-245003',
        'specializations': ['Emergency Care', 'Multi-specialty', 'Surgery', 'Orthopedics', '24x7 Service']
    },
    {
        'id': 'gh_hospital',
        'name': 'GH Hospital',
        'lat': 11.1696487,
        'lng': 76.956832,
        'rating': 4.6,
        'beds': 200,
        'icu': 25,
        'doctors': 70,
        'address': 'Government Hospital Road, Coimbatore District',
        'phone': '+91-4285-245004',
        'specializations': ['Emergency Care', '24x7 Service', 'Multi-specialty', 'Critical Care', 'ICU Care', 'Surgery']
    },
    {
        'id': 'sri_raj_hospital',
        'name': 'Sri Raj Hospital',
        'lat': 11.1631187,
        'lng': 76.9197141,
        'rating': 4.2,
        'beds': 90,
        'icu': 10,
        'doctors': 32,
        'address': 'Coimbatore District, Tamil Nadu',
        'phone': '+91-4285-245005',
        'specializations': ['Emergency Care', '24x7 Emergency', 'Trauma Care', 'General Medicine']
    },
    {
        'id': 'kr_hospital',
        'name': 'K R Hospital',
        'lat': 11.1481273,
        'lng': 76.9336793,
        'rating': 4.3,
        'beds': 110,
        'icu': 14,
        'doctors': 38,
        'address': 'Coimbatore District, Tamil Nadu',
        'phone': '+91-4285-245006',
        'specializations': ['Emergency Care', 'General Medicine', 'Surgery', 'Pediatrics', 'ICU Care']
    },
    {
        'id': 'sakthi_hospitals',
        'name': 'Sakthi Hospitals',
        'lat': 11.2995436,
        'lng': 76.8685783,
        'rating': 4.7,
        'beds': 180,
        'icu': 22,
        'doctors': 65,
        'address': 'Coimbatore, Tamil Nadu',
        'phone': '+91-4285-245007',
        'specializations': ['Emergency Care', '24x7 Service', 'Multi-specialty', 'Teaching Hospital', 'ICU Care', 'Trauma Center']
    },
    {
        'id': 'kps_hospitals',
        'name': 'KPS Hospitals (P) LTD',
        'lat': 11.2995436,
        'lng': 76.8685783,
        'rating': 4.7,
        'beds': 180,
        'icu': 22,
        'doctors': 65,
        'address': 'Coimbatore, Tamil Nadu',
        'phone': '+91-4285-245008',
        'specializations': ['Emergency Care', 'General Medicine', 'Surgery', 'Maternity', 'Pediatrics']
    },
]

def init_kongu_hospitals():
    """Initialize hospitals near Sree Sakthi Engineering College"""
    print("\n" + "="*70)
    print("🏥 INITIALIZING HOSPITALS NEAR SREE SAKTHI ENGINEERING COLLEGE")
    print("="*70)
    print(f"\n📍 Reference Point: Sree Sakthi Engineering College, Coimbatore")
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
        print(f"   📏 Distance: {distance:.2f} km from Sree Sakthi Engineering College")
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
    print("\n📊 HOSPITALS SORTED BY DISTANCE FROM SREE SAKTHI ENGINEERING COLLEGE:")
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
