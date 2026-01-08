<?php

namespace Database\Seeders;

use App\Models\Category;
use Illuminate\Database\Seeder;
use Illuminate\Support\Str;

class CategorySeeder extends Seeder
{
    /**
     * Run the database seeds.
     *
     * @return void
     */
    public function run()
    {
        // Define the list of categories for your marketplace
        $categories = [
            'Electronics',
            'Fashion',
            'Home & Living',
            'Hobbies',
            'Automotive',
            'Property',
            'Services'
        ];

        foreach ($categories as $name) {
            Category::create([
                'name' => $name,
                'slug' => Str::slug($name), // Converts "Home & Living" to "home-living"
            ]);
        }
    }
}
