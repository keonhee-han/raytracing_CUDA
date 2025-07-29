#ifndef HITTABLE_LIST_H
#define HITTABLE_LIST_H
//==============================================================================================
// Originally written in 2016 by Peter Shirley <ptrshrl@gmail.com>
//
// To the extent possible under law, the author(s) have dedicated all copyright and related and
// neighboring rights to this software to the public domain worldwide. This software is
// distributed without any warranty.
//
// You should have received a copy (see file COPYING.txt) of the CC0 Public Domain Dedication
// along with this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.
//==============================================================================================

#include "hittable.h"

// #include <vector>

// Assume `rtweekend.h` inclusion for `hittable_list.h`
// #include <memory>
// using std::make_shared;
// using std::shared_ptr;

class hittable_list : public hittable {
  public:
    // std::vector<shared_ptr<hittable>> objects;

    // hittable_list() {}
    // hittable_list(shared_ptr<hittable> object) { add(object); }
    __device__ hittable_list() {}
    __device__ hittable_list(hittable **l_, int n_) {list = l_; list_size = n_; }
    __device__ virtual bool hit(const ray& r_, float t_min, float t_max, hit_record& rec) const;
    hittable **list;
    int list_size;
};

    // void clear() { objects.clear(); }

    // void add(shared_ptr<hittable> object) {
    //     objects.push_back(object);
    // }

// hittable_list::hit() using `interval.h`
// bool hit(const ray& r, interval ray_t, hit_record& rec) const override {
__device__ bool hittable_list::hit(const ray& r_, float t_min, float t_max, hit_record& rec) const{
    hit_record temp_rec;
    bool hit_anything = false;
    float closest_so_far = t_max;
    // auto closest_so_far = ray_t.max;

    // for (const auto& object : objects) {
    for (int i_= 0; i_ < list_size; i_++) {
        if (list[i_]->hit(r_, t_min, closest_so_far, temp_rec)) {
        // if (object->hit(r, interval(ray_t.min, closest_so_far), temp_rec)) {
            hit_anything = true;
            closest_so_far = temp_rec.t;
            rec = temp_rec;
        }
    }
    return hit_anything;
}


#endif
