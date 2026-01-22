#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <mach/mach.h>
#import <mach-o/dyld.h>
#import "dobby.h" 

// ============================================================================
// [1] الأوفستات "النظيفة" (RVA) - بدون الـ 1 في البداية
// ============================================================================
static uintptr_t offsets[] = {
    0x2A8B68, 
    // 0x1002A8B68, // محذوف لأنه مكرر
    0x1C87200, 
    0x1C85C80, 
    0x1C86DF0, 
    0x1C851DC, 
    0x1947E04, 
    0x1948928, 
    0xC8293C, 
    0x1C42B90, 
    0x1C427F0, 
    0x1C41C70, 
    0x1C3F988, 
    0x15C7284, 
    0x5A47DC, 
    0x1C80474, 
    0x1C80710, 
    0x93AE94, 
    0x93F9A8, 
    0x1938A10, 
    0x193821C, 
    0x1936D54, 
    0x193504C, 
    0xC82804, 
    0xC827B8, 
    0xC8270C, 
    0xC81304, 
    0xC80DD4, 
    0xC80744, 
    0x757D4, 
    0x7559C, 
    0x75378, 
    0x7599C, 
    0x1C86920, 
    0x1C83A10, 
    0x1C88F30, 
    0x1C87B00
};

// ============================================================================
// [2] دالة التعطيل
// ============================================================================
void NullFunction() {
    return; 
}

// ============================================================================
// [3] المحرك (تم تعديله ليجلب العنوان الحقيقي - Header)
// ============================================================================
static const struct mach_header_64* GetImageHeader(const char *target) {
    uint32_t count = _dyld_image_count();
    for (uint32_t i = 0; i < count; i++) {
        const char *name = _dyld_get_image_name(i);
        if (name && strstr(name, target)) {
            // ⚠️ التغيير هنا: نرجع الهيدر (العنوان الحقيقي) بدلاً من السلايد
            return (const struct mach_header_64*)_dyld_get_image_header(i);
        }
    }
    return NULL;
}

// ============================================================================
// [4] نقطة التشغيل
// ============================================================================
__attribute__((constructor))
static void InitFixed() {
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        // 1. نحصل على عنوان بداية الملف في الذاكرة
        const struct mach_header_64* header = GetImageHeader("ShadowTrackerExtra");
        
        if (header != NULL) {
            uintptr_t baseAddr = (uintptr_t)header;
            int count = sizeof(offsets) / sizeof(offsets[0]);
            
            for (int i = 0; i < count; i++) {
                // 2. المعادلة الصحيحة: العنوان = البداية + الأوفست الصغير
                uintptr_t targetAddr = baseAddr + offsets[i];
                
                // 3. الحقن
                DobbyHook((void *)targetAddr, (void *)NullFunction, NULL);
            }
            
            NSLog(@"[Sovereign] ✅ Fixed Hook Applied on %d offsets.", count);
        } else {
             NSLog(@"[Sovereign] ❌ Game binary not found!");
        }
    });
}
